import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var age: Int = 18
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var showingPhotoCropper = false
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var rawSelectedImage: UIImage?
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var howDidYouHearAboutUs: String = "Select an option"
    
    // Callback for when onboarding is complete
    var onboardingComplete: (() -> Void)?
    
    // Age range for picker
    let ageRange = 13...100
    
    // How did you hear about us options
    let referralSources = [
        "Select an option",
        "Social Media (Instagram, TikTok, Twitter)",
        "Word of Mouth (Friend/Family)",
        "Google Search",
        "YouTube",
        "Podcast",
        "Sports Event/Game",
        "Advertisement",
        "App Store/Google Play",
        "Athlete/Influencer Recommendation",
        "Other"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Complete Your Profile")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Profile picture section
                VStack(spacing: 15) {
                    // Show croppedImage first, then user profile pic, then default
                    Group {
                        if let croppedImage = croppedImage {
                            Image(uiImage: croppedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                .shadow(color: .neonGreen.opacity(0.5), radius: 5)
                        } else if let user = authViewModel.user, !user.profilePicURL.isEmpty {
                            AsyncImage(url: URL(string: user.profilePicURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                    .shadow(color: .neonGreen.opacity(0.5), radius: 5)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.neonGreen)
                            }
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.neonGreen)
                                .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                        }
                    }
                    
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Add Photo")
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.neonGreen, lineWidth: 1)
                        )
                    }
                    .foregroundColor(.neonGreen)
                }
                .padding(.bottom, 10)
                
                TextField("First Name", text: $firstName)
                    .textFieldStyle(CustomTextFieldStyle())
                
                TextField("Last Name", text: $lastName)
                    .textFieldStyle(CustomTextFieldStyle())
                
                TextField("Username", text: $username)
                    .textFieldStyle(CustomTextFieldStyle())
                    .autocapitalization(.none)
                    .onAppear {
                        // Pre-fill username if available
                        if let user = authViewModel.user, !user.username.isEmpty {
                            username = user.username
                        }
                    }
                
                // Age picker
                HStack {
                    Text("Age")
                        .foregroundColor(.white)
                        .frame(width: 80, alignment: .leading)
                    
                    Picker("Select your age", selection: $age) {
                        ForEach(ageRange, id: \.self) { age in
                            Text("\(age)")
                                .foregroundColor(.white)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    .clipped()
                    .accentColor(.neonGreen)
                }
                .padding(.horizontal)
                
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.phonePad)
                
                // How did you hear about us picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("How did you hear about us?")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    Menu {
                        ForEach(referralSources, id: \.self) { source in
                            Button(action: {
                                howDidYouHearAboutUs = source
                            }) {
                                HStack {
                                    Text(source)
                                    if howDidYouHearAboutUs == source {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(howDidYouHearAboutUs)
                                .foregroundColor(howDidYouHearAboutUs == "Select an option" ? .gray : .white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.neonGreen)
                        }
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.neonGreen, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    saveUserData()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Text("Continue")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.neonGreen)
                .foregroundColor(.black)
                .cornerRadius(8)
                .disabled(firstName.isEmpty || lastName.isEmpty || username.isEmpty || phoneNumber.isEmpty || howDidYouHearAboutUs == "Select an option" || isLoading)
                .padding(.bottom, 30)
            }
            .padding()
            .background(Color.black)
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            hideKeyboard()
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                message: Text("Choose a source"),
                buttons: [
                    .default(Text("Photo Library")) {
                        showingImagePicker = true
                    },
                    .default(Text("Camera")) {
                        // TODO: Add camera functionality
                        showingImagePicker = true
                    },
                    .default(Text("Use Default Photo")) {
                        selectedImage = nil
                        croppedImage = nil
                        rawSelectedImage = nil
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $rawSelectedImage)
        }
        .sheet(isPresented: $showingPhotoCropper) {
            if let rawImage = rawSelectedImage {
                PhotoCropperView(
                    image: rawImage,
                    croppedImage: $croppedImage,
                    isPresented: $showingPhotoCropper
                )
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: rawSelectedImage) { newImage in
            if newImage != nil {
                showingPhotoCropper = true
            }
        }
    }
    
    func saveUserData() {
        guard let user = authViewModel.user else {
            alertMessage = "User not found. Please try signing in again."
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Use croppedImage if available, otherwise save without profile image
        if let imageToUpload = croppedImage {
            uploadProfileImage(imageToUpload, userId: user.uid) { result in
                switch result {
                case .success(let downloadURL):
                    self.updateUserProfile(user: user, profileImageURL: downloadURL.absoluteString)
                case .failure(let error):
                    self.isLoading = false
                    self.alertMessage = "Failed to upload image: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        } else {
            updateUserProfile(user: user, profileImageURL: "")
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Compress the image to reduce storage costs
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        // Create a storage reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Create a child reference - organize by user ID
        let profileImageRef = storageRef.child("profile_images/user_\(userId)/profile.jpg")
        
        // Upload the image data
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = profileImageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get the download URL
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not get download URL"])))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }
    
    private func updateUserProfile(user: User, profileImageURL: String) {
        // Update the user object with onboarding information
        let updatedUser = User(
            uid: user.uid,
            email: user.email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            profilePicURL: profileImageURL,
            age: age,
            phoneNumber: phoneNumber,
            bio: bio.isEmpty ? "New Signacer user" : bio,
            howDidYouHearAboutUs: howDidYouHearAboutUs
        )
        
        // Update Firestore with the new user data
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "username": username,
            "firstName": firstName,
            "lastName": lastName,
            "age": age,
            "phoneNumber": phoneNumber,
            "bio": bio.isEmpty ? "New Signacer user" : bio,
            "profilePicURL": profileImageURL,
            "howDidYouHearAboutUs": howDidYouHearAboutUs
        ]) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Failed to save profile: \(error.localizedDescription)"
                showingAlert = true
            } else {
                // Update the local user object
                authViewModel.user = updatedUser
                
                // Call the completion handler
                onboardingComplete?()
            }
        }
    }
}

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
