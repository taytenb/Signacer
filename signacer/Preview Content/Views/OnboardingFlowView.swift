import SwiftUI

struct OnboardingFlowView: View {
    @State private var didCompleteQRScan = false
    
    var body: some View {
        if !didCompleteQRScan {
            MembershipQRScanView { scannedCode in
                // (For now, we simply print the scanned code.)
                print("Membership QR Code scanned: \(scannedCode)")
                didCompleteQRScan = true
            }
        } else {
            OnboardingView()
        }
    }
} 