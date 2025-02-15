import SwiftUI

struct LoginOptionsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Signacer")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Button(action: {
                authViewModel.signInWithApple()
            }) {
                Text("Sign In with Apple")
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            Button(action: {
                authViewModel.signInWithGoogle()
            }) {
                Text("Sign In with Google")
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            
            NavigationLink(destination: LoginView()) {
                Text("Sign In Manually")
                    .foregroundColor(.neonGreen)
            }
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 