import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import AuthenticationServices
import CryptoKit
import GoogleSignIn

class AuthViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @Published var user: User? = nil
    @Published var isLoading = false
    @Published var error: String? = nil
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    override init() {
        super.init()
        
        // Store the listener handle
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.fetchUserData(userId: firebaseUser.uid)
            } else {
                self?.user = nil
            }
        }
    }
    
    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.isLoading = false
            if let error = error {
                self?.error = error.localizedDescription
                return
            }
            if let firebaseUser = authResult?.user {
                self?.fetchUserData(userId: firebaseUser.uid)
            }
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            self?.isLoading = false
            if let error = error {
                self?.error = error.localizedDescription
                completion(false)
                return
            }
            
            guard let firebaseUser = authResult?.user else {
                completion(false)
                return
            }
            
            // Create a new user with default values
            let newUser = User.defaultUser(uid: firebaseUser.uid, email: email)
            // Update the username
            let userWithUsername = User(
                uid: newUser.uid,
                email: newUser.email,
                username: username,
                firstName: newUser.firstName,
                lastName: newUser.lastName,
                profilePicURL: newUser.profilePicURL,
                age: newUser.age,
                phoneNumber: newUser.phoneNumber,
                bio: newUser.bio
            )
            
            FirestoreManager.shared.createUser(user: userWithUsername) { success in
                if success {
                    self?.user = userWithUsername
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        isLoading = true
        FirestoreManager.shared.fetchUser(userId: userId) { [weak self] user in
            self?.isLoading = false
            if let user = user {
                DispatchQueue.main.async {
                    self?.user = user
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
            }
        } catch let error {
            self.error = error.localizedDescription
        }
    }
    
    // Updating Apple Sign In to include completion handler
    func signInWithApple(completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        currentNonce = randomNonceString()
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(currentNonce!)
        
        let authController = ASAuthorizationController(authorizationRequests: [request])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
        
        // Store completion handler
        self.currentAuthCompletion = completion
    }
    
    // Updating Google Sign In to include completion handler
    func signInWithGoogle(completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { 
            self.isLoading = false
            completion(false, "Missing client ID")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            self.isLoading = false
            self.error = "Cannot find root view controller"
            completion(false, "Cannot find root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.error = error.localizedDescription
                completion(false, error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                let errorMsg = "Failed to get authentication data"
                self.error = errorMsg
                completion(false, errorMsg)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, 
                                                         accessToken: user.accessToken.tokenString)
            self.authenticateWithFirebase(credential: credential) { success, error in
                completion(success, error)
            }
        }
    }
    
    // Update Firebase authentication to include completion handler
    private func authenticateWithFirebase(credential: AuthCredential, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self else { 
                completion(false, "Self reference lost")
                return 
            }
            
            if let error = error {
                self.error = error.localizedDescription
                completion(false, error.localizedDescription)
                return
            }
            
            if let firebaseUser = authResult?.user {
                // Check if the user exists in Firestore
                FirestoreManager.shared.fetchUser(userId: firebaseUser.uid) { [weak self] user in
                    if let user = user {
                        // User exists, update the published user property
                        DispatchQueue.main.async {
                            self?.user = user
                            completion(true, nil)
                        }
                    } else {
                        // User doesn't exist, create a new user in Firestore
                        let email = firebaseUser.email ?? ""
                        let username = email.components(separatedBy: "@").first ?? "user"
                        
                        let newUser = User(
                            uid: firebaseUser.uid,
                            email: email,
                            username: username,
                            firstName: "",
                            lastName: "",
                            profilePicURL: firebaseUser.photoURL?.absoluteString ?? "",
                            age: 0,
                            phoneNumber: firebaseUser.phoneNumber ?? "",
                            bio: "New Signacer user"
                        )
                        
                        FirestoreManager.shared.createUser(user: newUser) { success in
                            if success {
                                DispatchQueue.main.async {
                                    self?.user = newUser
                                    completion(true, nil)
                                }
                            } else {
                                let errorMsg = "Failed to create user profile"
                                self?.error = errorMsg
                                completion(false, errorMsg)
                            }
                        }
                    }
                }
            } else {
                completion(false, "Failed to retrieve user")
            }
        }
    }
    
    func handleScannedCard(cardId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("cards").document(cardId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let athleteId = data["athleteId"] as? String ?? ""
                let rarity = data["rarity"] as? String ?? ""
                
                // Add card to user's collection
                FirestoreManager.shared.addCardToUser(
                    userId: userId,
                    cardId: cardId,
                    athleteId: athleteId,
                    rarity: rarity
                ) { success in
                    if success {
                        // Refresh user's cards if needed
                    }
                }
            }
        }
    }
    
    // MARK: - Apple Sign In Extensions
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
    
    // Update Apple Sign In delegate methods
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        self.isLoading = false
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce, let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                let errorMsg = "Unable to fetch identity token"
                self.error = errorMsg
                currentAuthCompletion?(false, errorMsg)
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            authenticateWithFirebase(credential: credential) { success, error in
                self.currentAuthCompletion?(success, error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.isLoading = false
        self.error = error.localizedDescription
        currentAuthCompletion?(false, error.localizedDescription)
    }
    
    // Adapted from Firebase documentation for nonce generation
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // SHA256 for nonce
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // For Apple Sign In nonce
    private var currentNonce: String?
    
    // Add a property to store current auth completion
    private var currentAuthCompletion: ((Bool, String?) -> Void)?
}
