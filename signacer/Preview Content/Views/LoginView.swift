import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var isRegistering = false
    @State private var showForgotPassword = false
    @State private var navigateToWelcome = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isRegistering ? "Create Account" : "Sign In")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            if isRegistering {
                TextField("Username", text: $username)
                    .textFieldStyle(CustomTextFieldStyle())
            }
            
            TextField("Email", text: $email)
                .textFieldStyle(CustomTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(CustomTextFieldStyle())
            
            Button(action: {
                if isRegistering {
                    // Simulate registration by creating a dummy user
                    let newUser = User(uid: UUID().uuidString, email: email, username: username, profilePicURL: "")
                    authViewModel.user = newUser
                    navigateToWelcome = true
                } else {
                    authViewModel.signIn(email: email, password: password)
                    navigateToWelcome = true
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
