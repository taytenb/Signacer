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
    @State private var showingPhotoCropper = false
    @State private var selectedImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var rawSelectedImage: UIImage?
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
                    // Show croppedImage first, then selectedImage, then user profile pic, then default
                    Group {
                        if let croppedImage = croppedImage {
                            Image(uiImage: croppedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                .shadow(color: .neonGreen.opacity(0.5), radius: 5)
                        } else if let user = authViewModel.user, !user.profilePicURL.isEmpty {
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
        .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            loadUserData()
        }
        .onChange(of: rawSelectedImage) { newImage in
            if newImage != nil {
                showingPhotoCropper = true
            }
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
        
        // Use croppedImage if available, otherwise use the original logic
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
            updateUserProfile(user: user, profileImageURL: user.profilePicURL)
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

// Modern Photo Cropper View - Instagram/TikTok style
struct PhotoCropperView: View {
    let image: UIImage
    @Binding var croppedImage: UIImage?
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private let cropSize: CGFloat = 280
    
    // Fixed orientation image
    private var fixedImage: UIImage {
        return image.fixedOrientation()
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    // Black background
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header with cancel/done
                        HStack {
                            Button("Cancel") {
                                isPresented = false
                            }
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            
                            Spacer()
                            
                            Text("Move and Scale")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Spacer()
                            
                            Button("Done") {
                                cropImage()
                                isPresented = false
                            }
                            .foregroundColor(.neonGreen)
                            .font(.system(size: 16, weight: .semibold))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                        
                        Spacer()
                        
                        // Main cropping area
                        ZStack {
                            // Full-size image as background - using fixedImage
                            Image(uiImage: fixedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .scaleEffect(scale)
                                .offset(offset)
                                .clipped()
                                .gesture(
                                    SimultaneousGesture(
                                        // Pinch to zoom
                                        MagnificationGesture()
                                            .onChanged { value in
                                                let delta = value / lastScale
                                                lastScale = value
                                                let newScale = scale * delta
                                                scale = max(0.5, min(newScale, 4.0))
                                            }
                                            .onEnded { _ in
                                                lastScale = 1.0
                                            },
                                        // Drag to move
                                        DragGesture()
                                            .onChanged { value in
                                                let newOffset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                                offset = newOffset
                                            }
                                            .onEnded { _ in
                                                lastOffset = offset
                                            }
                                    )
                                )
                            
                            // Overlay to darken everything outside the crop circle
                            ZStack {
                                // Dark overlay covering everything
                                Rectangle()
                                    .fill(Color.black.opacity(0.7))
                                    .frame(width: geometry.size.width, height: geometry.size.width)
                                
                                // Clear circle in the middle
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: cropSize, height: cropSize)
                                    .blendMode(.destinationOut)
                            }
                            .compositingGroup()
                            .allowsHitTesting(false)
                            
                            // Crop circle outline
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: cropSize, height: cropSize)
                                .allowsHitTesting(false)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        
                        Spacer()
                        
                        // Bottom controls
                        VStack(spacing: 20) {
                            // Zoom indicator
                            HStack {
                                Image(systemName: "minus.magnifyingglass")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 14))
                                
                                Slider(value: $scale, in: 0.5...4.0)
                                    .accentColor(.neonGreen)
                                    .frame(maxWidth: 200)
                                
                                Image(systemName: "plus.magnifyingglass")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 30)
                            
                            // Instructions
                            VStack(spacing: 8) {
                                Text("Drag to reposition")
                                    .foregroundColor(.white.opacity(0.8))
                                    .font(.system(size: 14))
                                Text("Pinch to zoom")
                                    .foregroundColor(.white.opacity(0.6))
                                    .font(.system(size: 12))
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            autoFitImage()
        }
    }
    
    private func autoFitImage() {
        let imageSize = fixedImage.size // Use fixed image size
        let imageAspectRatio = imageSize.width / imageSize.height
        
        // Calculate initial scale to fit image nicely in crop area
        let minDimension = min(imageSize.width, imageSize.height)
        scale = cropSize / minDimension * 1.1
        
        // Ensure reasonable bounds
        scale = max(0.8, min(scale, 2.0))
    }
    
    private func cropImage() {
        // Create high-resolution output
        let outputSize = CGSize(width: cropSize * 2, height: cropSize * 2) // 2x for retina quality
        
        let renderer = UIGraphicsImageRenderer(size: outputSize)
        
        let croppedImg = renderer.image { context in
            // Create circular clipping path
            let clipPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
            clipPath.addClip()
            
            // Calculate how the image appears in the display
            let displaySize = UIScreen.main.bounds.width // The image display area is square
            
            // Calculate the image's natural display size (before scaling) - using fixedImage
            let imageSize = fixedImage.size
            let imageAspectRatio = imageSize.width / imageSize.height
            
            var naturalDisplayWidth: CGFloat
            var naturalDisplayHeight: CGFloat
            
            if imageAspectRatio > 1 {
                // Wide image - fit to height
                naturalDisplayHeight = displaySize
                naturalDisplayWidth = naturalDisplayHeight * imageAspectRatio
            } else {
                // Tall or square image - fit to width
                naturalDisplayWidth = displaySize
                naturalDisplayHeight = naturalDisplayWidth / imageAspectRatio
            }
            
            // Apply the user's scale
            let scaledDisplayWidth = naturalDisplayWidth * scale
            let scaledDisplayHeight = naturalDisplayHeight * scale
            
            // Calculate the crop region in display coordinates
            let cropCenterX = displaySize / 2
            let cropCenterY = displaySize / 2
            
            // Calculate image center in display coordinates (with offset)
            let imageCenterX = displaySize / 2 + offset.width
            let imageCenterY = displaySize / 2 + offset.height
            
            // Calculate the crop region relative to the image
            let cropRelativeX = cropCenterX - imageCenterX
            let cropRelativeY = cropCenterY - imageCenterY
            
            // Convert to image coordinates
            let imageScaleX = imageSize.width / scaledDisplayWidth
            let imageScaleY = imageSize.height / scaledDisplayHeight
            
            let cropInImageX = (cropRelativeX * imageScaleX) + (imageSize.width / 2)
            let cropInImageY = (cropRelativeY * imageScaleY) + (imageSize.height / 2)
            
            // Calculate the crop region in image coordinates
            let cropRadiusInImage = (cropSize / 2) * imageScaleX
            
            let sourceRect = CGRect(
                x: cropInImageX - cropRadiusInImage,
                y: cropInImageY - cropRadiusInImage,
                width: cropRadiusInImage * 2,
                height: cropRadiusInImage * 2
            )
            
            // Draw only the cropped portion of the image - using fixedImage
            if let cgImage = fixedImage.cgImage,
               let croppedCGImage = cgImage.cropping(to: sourceRect) {
                let croppedUIImage = UIImage(cgImage: croppedCGImage)
                croppedUIImage.draw(in: CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
            } else {
                // Fallback: draw the full image scaled to fit - using fixedImage
                let drawRect = CGRect(
                    x: -cropRelativeX * (outputSize.width / cropSize),
                    y: -cropRelativeY * (outputSize.height / cropSize),
                    width: scaledDisplayWidth * (outputSize.width / cropSize),
                    height: scaledDisplayHeight * (outputSize.height / cropSize)
                )
                fixedImage.draw(in: drawRect)
            }
        }
        
        croppedImage = croppedImg
    }
}

// Updated Image Picker with camera support
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
        picker.sourceType = sourceType
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed 
    }
}

//// Extension for neon green color
//extension Color {
//    static let neonGreen = Color(red: 0, green: 1, blue: 0.5)
//}

// I love the world and cherish it wholeheartedly

// MARK: - UIImage Extension for Orientation Fix
extension UIImage {
    func fixedOrientation() -> UIImage {
        // If the image is already in the correct orientation, return it
        if imageOrientation == .up {
            return self
        }
        
        // Get the image size
        let size = self.size
        
        // Create a graphics context
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        // Draw the image in the correct orientation
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        // Get the corrected image
        guard let correctedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        
        return correctedImage
    }
}
