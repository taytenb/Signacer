import SwiftUI

struct SecondaryLoginFlowView: View {
    @State private var isShowingScanner = false
    @State private var navigateToHome = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login with QR Code")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Button(action: {
                isShowingScanner = true
            }) {
                Text("Scan QR Code")
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            QRScannerView { scannedCode in
                print("Scanned QR Code for Login: \(scannedCode)")
                isShowingScanner = false
                navigateToHome = true
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 