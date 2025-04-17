import SwiftUI
import Firebase
import FirebaseFirestore

struct OnboardingView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var age: Int = 18
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // Callback for when onboarding is complete
    var onboardingComplete: (() -> Void)?
    
    // Age range for picker
    let ageRange = 13...100
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Complete Your Profile")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                // Profile picture preview (default)
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.neonGreen)
                    .padding(.bottom, 20)
                
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
                
                // Bio text editor
                VStack(alignment: .leading) {
                    Text("Bio")
                        .foregroundColor(.white)
                        .padding(.leading, 5)
                    
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .padding(10)
                        .background(Color(white: 0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.neonGreen, lineWidth: 1)
                        )
                }
                
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
                .disabled(firstName.isEmpty || lastName.isEmpty || username.isEmpty || phoneNumber.isEmpty || isLoading)
                .padding(.bottom, 30)
            }
            .padding()
            .background(Color.black)
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func saveUserData() {
        guard let user = authViewModel.user else {
            alertMessage = "User not found. Please try signing in again."
            showingAlert = true
            return
        }
        
        isLoading = true
        
        // Update the user object with onboarding information
        let updatedUser = User(
            uid: user.uid,
            email: user.email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            profilePicURL: "",
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
            "profilePicURL": ""
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