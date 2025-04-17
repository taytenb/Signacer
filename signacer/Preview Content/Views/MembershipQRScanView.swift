import SwiftUI

struct MembershipQRScanView: View {
    var onScanCompletion: (String) -> Void
    @State private var showScanner = true
    @State private var isScanning = true
    
    // Check if we're running on a Mac or in a simulator
    #if targetEnvironment(macCatalyst) || os(macOS)
    let isRunningOnMac = true
    #else
    let isRunningOnMac = false
    #endif
    
    // Check if we're running in a simulator
    #if targetEnvironment(simulator)
    let isSimulator = true
    #else
    let isSimulator = false
    #endif
    
    // Determine if we should skip scanning and auto-proceed
    var shouldSkipScanning: Bool {
        return isRunningOnMac || isSimulator
    }
    
    var body: some View {
        ZStack {
            if showScanner && !shouldSkipScanning {
                QRScannerView { scannedCode in
                    print("QR Code scanned: \(scannedCode)")
                    isScanning = false
                    onScanCompletion(scannedCode)
                }
            }
            
            VStack(spacing: 20) {
                Text(shouldSkipScanning ? "Processing..." : "Scanning Membership Card...")
                    .font(.title)
                    .foregroundColor(.white)
                
                if shouldSkipScanning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
        }
        .onAppear {
            // On Mac or simulator, simulate a successful QR scan after a 2-second delay
            if shouldSkipScanning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    onScanCompletion("dummyQR")
                }
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 