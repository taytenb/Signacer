import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingQRScanner = false
    @State private var navigateToOnboarding = false
    @State private var navigateToHome = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Signacer")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Button(action: {
                isShowingQRScanner = true
            }) {
                Text("Scan Your Membership Card")
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isShowingQRScanner) {
            QRScannerView { scannedCode in
                print("Scanned QR Code: \(scannedCode)")
                isShowingQRScanner = false
                
                // Check if user needs onboarding
                if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                    navigateToOnboarding = true
                } else {
                    navigateToHome = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToOnboarding) {
            OnboardingView()
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}
