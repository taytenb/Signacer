import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    private let db = Firestore.firestore()
    
    init() {
        // Listen to Firebase Auth changes.
        Auth.auth().addStateDidChangeListener { [weak self] auth, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.fetchUserData(userId: firebaseUser.uid)
            } else {
                self?.user = nil
            }
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            if let firebaseUser = authResult?.user {
                self?.fetchUserData(userId: firebaseUser.uid)
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let user = User(
                    uid: userId,
                    email: data["email"] as? String ?? "",
                    username: data["username"] as? String ?? "User",
                    profilePicURL: data["profilePicURL"] as? String ?? ""
                )
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
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // Stub for Apple Sign In (you would use AuthenticationServices)
    func signInWithApple() {
        // TODO: Implement real Apple login.
        let dummyUser = User(uid: "appleUser", email: "apple@example.com", username: "AppleUser", profilePicURL: "")
        self.user = dummyUser
    }
    
    // Stub for Google Sign In (requires importing GoogleSignIn SDK)
    func signInWithGoogle() {
        // TODO: Implement real Google login.
        let dummyUser = User(uid: "googleUser", email: "google@example.com", username: "GoogleUser", profilePicURL: "")
        self.user = dummyUser
    }
    
    func handleScannedCard(cardId: String) {
        let db = Firestore.firestore()
        db.collection("cards").document(cardId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data() ?? [:]
                let athleteId = data["athleteId"] as? String ?? ""
                
                // Now fetch athlete data
                db.collection("athletes").document(athleteId).getDocument { athleteDoc, error in
                    if let athleteDoc = athleteDoc, athleteDoc.exists {
                        // Create Athlete object and update UI
                        let athleteData = athleteDoc.data() ?? [:]
                        let athlete = Athlete(
                            id: athleteId,
                            name: athleteData["name"] as? String ?? "",
                            profilePicURL: athleteData["profilePicURL"] as? String ?? "",
                            highlightVideoURL: athleteData["highlightVideoURL"] as? String ?? "",
                            perks: [],  // Fetch from subcollection if needed
                            events: [],
                            communities: [],
                            giveaways: [],
                            contentURL: athleteData["contentURL"] as? String ?? "",
                            products: []
                        )
                        
                        // Update UI with athlete data
                    }
                }
            }
        }
    }
}
