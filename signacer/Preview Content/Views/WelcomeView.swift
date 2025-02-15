import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingQRScanner = false

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
            
            NavigationLink(destination: LoginView()) {
                Text("Already have an account? Sign In")
                    .foregroundColor(.neonGreen)
            }
        }
        .sheet(isPresented: $isShowingQRScanner) {
            QRScannerView { scannedCode in
                // Process the scanned QR code. For now, simply print it.
                print("Scanned QR Code: \(scannedCode)")
                isShowingQRScanner = false
                // You could trigger sign-up or validation here.
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}
