import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Add padding to push content down from top
                Spacer()
                    .frame(height: 50)
                
                // Top banner image
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.neonGreen.opacity(0.7), Color.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(height: 100)
                    .clipped()
                
                // Profile Header
                VStack(spacing: 16) {
                    // Profile Image (positioned to overlap the banner)
                    if let user = authViewModel.user, user.profilePicURL != "default_profile" {
                        Image(user.profilePicURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                            .offset(y: -60)
                            .padding(.bottom, -60)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .foregroundColor(.neonGreen)
                            .background(Color.black)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                            .offset(y: -60)
                            .padding(.bottom, -60)
                    }
                    
                    // User Info
                    VStack(spacing: 8) {
                        // Display full name if available
                        if let user = authViewModel.user, !user.firstName.isEmpty && !user.lastName.isEmpty {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                        }
                        
                        Text("@\(authViewModel.user?.username ?? "itvsjmoney")")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text(authViewModel.user?.email ?? "jaren@example.com")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(authViewModel.user?.age ?? 25)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Age")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                                .frame(height: 20)
                                .background(Color.gray.opacity(0.3))
                            
                            VStack {
                                Text("2024")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Joined")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Bio
                        Text(authViewModel.user?.bio ?? "Book lover, sports fanatic, and lifelong fan of The Weeknd. Whether I'm diving into a great novel, catching the latest game, or vibing to XO classics, I'm all about passion and community.")
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                    }
                }
                .padding(.vertical, 24)
                
                // Activity Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Activity")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        ActivityCard(title: "Cards", value: "5", iconName: "creditcard.fill")
                        ActivityCard(title: "Events", value: "2", iconName: "calendar")
                        ActivityCard(title: "Athletes", value: "3", iconName: "person.fill")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // My Cards Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Cards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            CardView(image: "Jersey", title: "Game Jersey")
                            CardView(image: "WBrand", title: "Athlete Brand")
                            CardView(image: "Gatorade", title: "Sponsor")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                
                // Settings Button
                Button(action: { showSettings = true }) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.neonGreen)
                        
                        Text("Settings")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.neonGreen, lineWidth: 1)
                    )
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                
                // Admin Button - Only shown for your account
                if authViewModel.user?.uid == "Ufq2rniOciUcDa0lqh5B2wZXe6F3" {
                    NavigationLink(destination: AdminView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.red)
                            
                            Text("Admin Panel")
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
                
                Spacer()
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showSettings) {
            Text("Settings View Placeholder")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// Helper views
struct ActivityCard: View {
    let title: String
    let value: String
    let iconName: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.neonGreen)
                .padding(.bottom, 5)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CardView: View {
    let image: String
    let title: String
    
    var body: some View {
        VStack {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 120)
        }
    }
}
