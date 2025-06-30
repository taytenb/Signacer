import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                // Logo positioned at the top
                VStack {
                    Image("SignacerCropped")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 150)
                        .clipped()
                        .padding(.top, 60) // Adjust this value to position higher or lower
                    
                    Spacer()
                }
                
                // Main content centered
                VStack(spacing: 20) {
                    Spacer()
                    
                    Text("Welcome to Signacer")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        // Apple Sign In Button
                        Button(action: {
                            authViewModel.signInWithApple { success, error in
                                if !success, let error = error {
                                    errorMessage = error
                                    showErrorAlert = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                
                                Spacer()
                                
                                Text("Sign Up with Apple")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Spacer()
                                    .frame(width: 24)  // Match icon width to maintain center alignment
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.neonGreen)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                        
                        // Google Sign In Button
                        Button(action: {
                            authViewModel.signInWithGoogle { success, error in
                                if !success, let error = error {
                                    errorMessage = error
                                    showErrorAlert = true
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                                
                                Spacer()
                                
                                Text("Sign Up with Google")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Spacer()
                                    .frame(width: 24)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.neonGreen)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Sign Up Manually")
                                .foregroundColor(.neonGreen)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Authentication Error"), 
                      message: Text(errorMessage), 
                      dismissButton: .default(Text("OK")))
            }
        }
    }
} 
