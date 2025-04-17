import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isRegistering = false
    @State private var showForgotPassword = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isRegistering ? "Create Account" : "Sign In")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            
            TextField("Email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
            
            if isRegistering {
                TextField("Username", text: $username)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            Button(action: {
                if isRegistering {
                    // Use proper Firebase authentication
                    if !email.isEmpty && !password.isEmpty && !username.isEmpty {
                        authViewModel.signUp(email: email, password: password, username: username) { success in
                            if success {
                                // Navigation will be handled by the AuthViewModel through the user state change
                            } else {
                                alertMessage = authViewModel.error ?? "Registration failed"
                                showingAlert = true
                            }
                        }
                    } else {
                        alertMessage = "Please fill in all fields"
                        showingAlert = true
                    }
                } else {
                    authViewModel.signIn(email: email, password: password)
                    // Navigation will be handled by the AuthViewModel through the user state change
                }
            }) {
                Text(isRegistering ? "Create Account" : "Sign In")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Button(action: { isRegistering.toggle() }) {
                Text(isRegistering ? "Already have an account? Sign In" : "Need an account? Register")
                    .foregroundColor(.neonGreen)
            }
            
            if !isRegistering {
                Button(action: { showForgotPassword = true }) {
                    Text("Forgot Password?")
                        .foregroundColor(.neonGreen)
                }
            }
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(white: 0.2))
            .foregroundColor(.white)
            .cornerRadius(8)
            .autocapitalization(.none)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.neonGreen, lineWidth: 1)
            )
    }
}
