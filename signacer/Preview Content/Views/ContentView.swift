import SwiftUI
import Firebase

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @State private var showingSplash = true
    
    var body: some View {
        Group {
            if showingSplash {
                SplashView()
            } else if authViewModel.user == nil {
                // User not authenticated - show sign in
                NavigationView {
                    SignInView()
                }
            } else {
                // User is authenticated - check if onboarding is needed
                AuthenticatedFlowCoordinator()
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

// A coordinator view that handles the flow after authentication
struct AuthenticatedFlowCoordinator: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(onboardingComplete: {
                    hasCompletedOnboarding = true
                })
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            // Check if the user has completed onboarding
            if let user = authViewModel.user {
                // If user has age and phone number data, consider onboarding complete
                hasCompletedOnboarding = user.age > 0 && !user.phoneNumber.isEmpty
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
