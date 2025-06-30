import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingQRScanner = false
    @State private var navigateToHome = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
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
                    .padding(.top, 160) 
                
                Spacer()
            }
            
            // Main content centered
            VStack(spacing: 20) {
                Spacer()
                
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
                
                // Button(action: {
                //     // Skip QR scanning and go directly to home
                //     navigateToHome = true
                // }) {
                //     Text("Continue Without Scanning")
                //         .padding()
                //         .background(Color.clear)
                //         .foregroundColor(.neonGreen)
                //         .overlay(
                //             RoundedRectangle(cornerRadius: 8)
                //                 .stroke(Color.neonGreen, lineWidth: 1)
                //         )
                // }
                
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingQRScanner) {
            MembershipQRScanView { scannedCode in
                isShowingQRScanner = false
                
                if let cardId = scannedCode {
                    print("Scanned QR Code: \(cardId)")

                    navigateToHome = true
                    // // Process the scanned QR code with the authViewModel
                    // authViewModel.handleScannedCard(cardId: cardId) { success, error in
                    //     if success {
                    //         navigateToHome = true
                    //     } else {
                    //         alertMessage = error ?? "Failed to process card"
                    //         showingAlert = true
                    //     }
                    // }
                } else {
                    // User cancelled or scan failed - just go to home
                    alertMessage = "Failed to process card"
                    showingAlert = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
        .alert("Card Processing Error", isPresented: $showingAlert) {
            Button("Try Again") {
                isShowingQRScanner = false
            }
        } message: {
            Text(alertMessage)
        }
    }
}
