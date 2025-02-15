import SwiftUI

struct MembershipQRScanView: View {
    @State private var isShowingScanner = false
    var onScanCompletion: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Your Membership Card")
                .font(.title)
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
                onScanCompletion(scannedCode)
                isShowingScanner = false
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 