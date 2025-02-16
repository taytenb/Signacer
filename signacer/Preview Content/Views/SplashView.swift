import SwiftUI
import AVKit

struct SplashView: View {
    @State private var isFinished = false
    
    var body: some View {
        ZStack {
            // Video player or animation here
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("SignacerLogo") // Placeholder for logo
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.neonGreen)
                    .scaleEffect(isFinished ? 1.2 : 1.0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                isFinished = true
            }
            // Delay to show animation before transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isFinished = true
            }
        }
    }
} 
