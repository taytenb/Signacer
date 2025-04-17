import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var age: Int = 18
    @State private var phoneNumber: String = ""
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Age range for picker
    let ageRange = 13...100
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Profile picture section
                VStack(spacing: 15) {
                    if let user = authViewModel.user, !user.profilePicURL.isEmpty {
                        AsyncImage(url: URL(string: user.profilePicURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                .shadow(color: .neonGreen.opacity(0.5), radius: 5)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .foregroundColor(.neonGreen)
                        }
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 140, height: 140)
                            .foregroundColor(.neonGreen)
                            .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                    }
                    
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Change Photo")
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
                .padding(.top, 60)  // Start content lower
                
                // Form fields
                VStack(spacing: 20) {
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    TextField("Username", text: $username)
                        .textFieldStyle(CustomTextFieldStyle())
                        .autocapitalization(.none)
                    
                    // Age picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Age")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.leading, 5)
                        
                        HStack {
                            Spacer()
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
                            Spacer()
                        }
                        .padding(8)
                        .background(Color(white: 0.15))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.neonGreen, lineWidth: 1)
                        )
                    }
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.phonePad)
                    
                    // Bio text editor
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bio")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.leading, 5)
                        
                        TextEditor(text: $bio)
                            .frame(height: 120)
                            .padding(10)
                            .background(Color(white: 0.15))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.neonGreen, lineWidth: 1)
                            )
                    }
                }
                .padding(.top, 10)
                
                // Save button
                Button(action: {
                    saveProfileData()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        } else {
                            Text("Save Changes")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.neonGreen)
                            .shadow(color: .neonGreen.opacity(0.5), radius: 5)
                    )
                }
                .foregroundColor(.black)
                .disabled(firstName.isEmpty || lastName.isEmpty || username.isEmpty || phoneNumber.isEmpty || isLoading)
                .padding(.top, 15)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 25)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                message: Text("Choose a source"),
                buttons: [
                    .default(Text("Photo Library")) {
                        showingImagePicker = true
                    },
                    .default(Text("Use Default Photo")) {
                        // Reset to default profile picture
                        selectedImage = nil
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        guard let user = authViewModel.user else { return }
        
        firstName = user.firstName
        lastName = user.lastName
        username = user.username
        bio = user.bio
        age = user.age
        phoneNumber = user.phoneNumber
    }
    
    private func saveProfileData() {
        guard let user = authViewModel.user else {
            alertMessage = "User not found. Please try signing in again."
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Handle image upload first if there's a new image
        if let imageToUpload = selectedImage {
            uploadProfileImage(imageToUpload, userId: user.uid) { result in
                switch result {
                case .success(let downloadURL):
                    // Continue with user profile update using the new image URL
                    self.updateUserProfile(user: user, profileImageURL: downloadURL.absoluteString)
                case .failure(let error):
                    self.isLoading = false
                    self.alertMessage = "Failed to upload image: \(error.localizedDescription)"
                    self.showingAlert = true
                }
            }
        } else {
            // No new image, just update the profile with existing image URL
            updateUserProfile(user: user, profileImageURL: user.profilePicURL)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (Result<URL, Error>) -> Void) {
        // Compress the image to reduce storage costs
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        // Create a storage reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Create a child reference - organize by user ID
        // This creates a path like: profile_images/user_ABC123/profile.jpg
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
        // Update the user object with new information
        let updatedUser = User(
            uid: user.uid,
            email: user.email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            profilePicURL: profileImageURL,
            age: age,
            phoneNumber: phoneNumber,
            bio: bio.isEmpty ? "New Signacer user" : bio
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
            "profilePicURL": profileImageURL
        ]) { error in
            isLoading = false
            
            if let error = error {
                alertMessage = "Failed to save profile: \(error.localizedDescription)"
                showingAlert = true
            } else {
                // Update the local user object
                authViewModel.user = updatedUser
                
                // Dismiss the view
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Image Picker helper
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed
    }
} 