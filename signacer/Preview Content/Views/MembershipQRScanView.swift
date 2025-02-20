import SwiftUI

struct MembershipQRScanView: View {
    var onScanCompletion: (String) -> Void
    @State private var showScanner = true
    
    var body: some View {
        ZStack {
            if showScanner {
                QRScannerView { scannedCode in
                    print("QR Code scanned: \(scannedCode)")
                    onScanCompletion(scannedCode)
                }
            }
            
            VStack(spacing: 20) {
                Text("Scanning Membership Card...")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            // Simulate a successful QR scan after a 2-second delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onScanCompletion("dummyQR")
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 