import SwiftUI
import AVKit

struct SplashView: View {
    @State private var isFinished = false
    
    var body: some View {
        ZStack {
            // Video player or animation here
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("SignacerCropped") // Placeholder for logo
                    .resizable()
                    .frame(width: 400, height: 150)
                    .foregroundColor(.neonGreen)
                    .scaleEffect(isFinished ? 1.2 : 1.0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                isFinished = true
            }
            // Delay to show animation before transitioning
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                isFinished = true
            }
        }
    }
} 
