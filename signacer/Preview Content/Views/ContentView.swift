import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @State private var showingSplash = true
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        Group {
            if showingSplash {
                SplashView()
            } else if authViewModel.user == nil {
                // No Firebase user: show login options.
                NavigationView {
                    LoginOptionsView()
                }
            } else if !hasCompletedOnboarding {
                // User is signed in but hasn't completed initial onboarding.
                OnboardingFlowView()
            } else {
                // Returning user flow—show "login with QR code" first.
                SecondaryLoginFlowView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showingSplash = false
                }
            }
        }
        .environmentObject(authViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
