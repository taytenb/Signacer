import SwiftUI

struct MembershipQRScanView: View {
    var onScanCompletion: (String?) -> Void
    @State private var showScanner = true
    @State private var isScanning = true
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
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
                QRScannerView { result in
                    switch result {
                    case .success(let scannedCode):
                        print("QR Code scanned successfully: \(scannedCode)")
                        isScanning = false
                        onScanCompletion(scannedCode)
                    case .failure(let error):
                        print("QR Code scan failed: \(error.localizedDescription)")
                        isScanning = false
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                    }
                }
                .cornerRadius(20)
                .clipped()
                .padding()
            }
            
            VStack(spacing: 20) {
                // Text(shouldSkipScanning ? "Processing..." : (isScanning ? "Scanning Membership Card..." : "Scan Complete"))
                //     .font(.title)
                //     .foregroundColor(.white)
                
                if shouldSkipScanning {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                if !isScanning && !shouldSkipScanning {
                    Button("Try Again") {
                        isScanning = true
                        showScanner = true
                    }
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
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
        .alert("Scan Error", isPresented: $showingErrorAlert) {
            Button("Try Again") {
                isScanning = true
                showScanner = true
                showingErrorAlert = false
            }
            Button("Cancel") {
                onScanCompletion(nil)
            }
        } message: {
            Text(errorMessage)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
} 