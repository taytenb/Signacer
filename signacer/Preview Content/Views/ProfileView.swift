import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAthletePage = false
    @State private var showSettings = false
    
    // Sample athlete data (replace with real data from Firebase)
    let sampleAthlete = Athlete(
        id: "athlete1",
        name: "Justin Jefferson",
        profilePicURL: "",
        highlightVideoURL: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
        perks: [Perk(id: "perk1", title: "15% off Amazon", link: "https://amazon.com")],
        events: [Event(id: "event1", title: "Stadium Tour", description: "Tour the stadium", date: Date())],
        communities: [Community(id: "comm1", title: "Discord Community", link: "https://discord.com")],
        giveaways: [Giveaway(id: "give1", title: "Jersey Giveaway", description: "Win a jersey!")],
        contentURL: "https://youtube.com",
        products: [Product(id: "prod1", title: "Justin Jefferson Jersey", description: "High-quality jersey", link: "https://justinjefferson.com")]
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.neonGreen)
                        .overlay(
                            Circle()
                                .stroke(Color.neonGreen, lineWidth: 2)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("@\(authViewModel.user?.username ?? "User")")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("Member since 2024")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .foregroundColor(.neonGreen)
                    }
                }
                .padding()
                
                // Cards Collection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<3) { _ in
                            CardView()
                                .onTapGesture {
                                    showAthletePage = true
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showAthletePage) {
            AthleteView(athlete: sampleAthlete)
        }
    }
}

struct CardView: View {
    var body: some View {
        VStack {
            Text("Justin Jefferson")
                .foregroundColor(.white)
            Text("1 of 100")
                .font(.caption)
                .foregroundColor(.neonGreen)
        }
        .frame(width: 150, height: 200)
        .background(Color.black)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.neonGreen, lineWidth: 1)
        )
    }
}
