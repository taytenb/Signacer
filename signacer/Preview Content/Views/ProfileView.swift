import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.neonGreen)
                        .overlay(
                            Circle()
                                .stroke(Color.neonGreen, lineWidth: 2)
                        )
                    
                    // User Info
                    VStack(spacing: 8) {
                        Text("@\(authViewModel.user?.username ?? "User")")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(authViewModel.user?.email ?? "email@example.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("\(authViewModel.user?.age ?? 0) years old")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Member since 2024")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 24)
                
                // Settings Button
                HStack {
                    Spacer()
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(.neonGreen)
                            .font(.title2)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}
