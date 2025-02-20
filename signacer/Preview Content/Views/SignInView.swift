import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Signacer")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Button(action: {
                // Simulated signup with Apple
                authViewModel.signInWithApple()
            }) {
                Text("Sign Up with Apple")
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Button(action: {
                // Simulated signup with Google
                authViewModel.signInWithGoogle()
            }) {
                Text("Sign Up with Google")
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            NavigationLink(destination: LoginView()) {
                Text("Sign Up Manually")
                    .foregroundColor(.neonGreen)
            }
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 