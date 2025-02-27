import SwiftUI

struct HomeView: View {
    @State private var navigateToProfile = false
    // Assuming you store the username in UserDefaults during onboarding
    private var username: String {
        UserDefaults.standard.string(forKey: "username") ?? "User"
    }
    
    let sampleAthlete = Athlete(
        id: "athlete1",
        name: "Justin Jefferson",
        profilePicURL: "AthleteJJ",
        highlightVideoURL: "JJGIF.gif",
        perks: [
            Perk(id: "perk1", title: "15% off Amazon", link: "https://amazon.com", imageURL: "Amazon"),
            Perk(id: "perk2", title: "10% off Gatorade", link: "https://gatorade.com", imageURL: "Gatorade"),
            Perk(id: "perk3", title: "5% off Under Armor", link: "https://underarmour.com", imageURL: "Underarmour")
        ],
        events: [
            Event(
                id: "event1",
                title: "Stadium Tour",
                description: "Tour the stadium",
                date: Date(),
                location: "US Bank Stadium",
                maxGuests: 50,
                isRSVPed: false,
                imageURL: "StadiumTour"
            ),
            Event(
                id: "event2",
                title: "Autograph Session",
                description: "Get an autograph from Justin Jefferson",
                date: Date(),
                location: "US Bank Stadium",
                maxGuests: 50,
                isRSVPed: false,
                imageURL: "auto"
            )
        ],
        communities: [Community(id: "comm1", title: "Discord Community", link: "https://discord.com", imageURL: "Discord")],
        giveaways: [
            Giveaway(
                id: "give1",
                title: "Jersey Giveaway",
                description: "Win a game worn jersey!",
                imageURL: "Jersey",
                endDate: Date().addingTimeInterval(7*24*60*60),
                isEntered: false
            ),
            Giveaway(
                id: "give2",
                title: "Ticket Giveaway",
                description: "Win a ticket to a game",
                imageURL: "tickets",
                endDate: Date().addingTimeInterval(7*24*60*60),
                isEntered: false
            )
        ],
        contentURL: "https://youtube.com"
    )
    // Mock data for athlete cards - replace with your actual data model
    private let athleteCards: [AthleteCard] = [
        AthleteCard(
            athlete: Athlete(
                id: "athlete1",
                name: "Justin Jefferson",
                profilePicURL: "AthleteJJ",
                highlightVideoURL: "JJGIF.gif",
                perks: [
                    Perk(id: "perk1", title: "15% off Amazon", link: "https://amazon.com", imageURL: "Amazon"),
                    Perk(id: "perk2", title: "10% off Gatorade", link: "https://gatorade.com", imageURL: "Gatorade"),
                    Perk(id: "perk3", title: "5% off Under Armor", link: "https://underarmour.com", imageURL: "Underarmour")
                ],
                events: [
                    Event(
                        id: "event1",
                        title: "Stadium Tour",
                        description: "Tour the stadium",
                        date: Date(),
                        location: "US Bank Stadium",
                        maxGuests: 50,
                        isRSVPed: false,
                        imageURL: "StadiumTour"
                    ),
                    Event(
                        id: "event2",
                        title: "Autograph Session",
                        description: "Get an autograph from Justin Jefferson",
                        date: Date(),
                        location: "US Bank Stadium",
                        maxGuests: 50,
                        isRSVPed: false,
                        imageURL: "auto"
                    )
                ],
                communities: [Community(id: "comm1", title: "Discord Community", link: "https://discord.com", imageURL: "Discord")],
                giveaways: [
                    Giveaway(
                        id: "give1",
                        title: "Jersey Giveaway",
                        description: "Win a jersey!",
                        imageURL: "Jersey",
                        endDate: Date().addingTimeInterval(7*24*60*60),
                        isEntered: false    
                    ),
                    Giveaway(
                        id: "give2",
                        title: "Ticket Giveaway",
                        description: "Win a ticket to a game",
                        imageURL: "tickets",
                        endDate: Date().addingTimeInterval(7*24*60*60),
                        isEntered: false
                    )
                ],
                contentURL: "https://youtube.com"
            ),
            backgroundImage: "JustinJefferson",
            rarity: "1/100"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Picture and Navigation
                    HStack {
                        Spacer()
                        NavigationLink(
                            destination: ProfileView(),
                            isActive: $navigateToProfile
                        ) { EmptyView() }
                        
                        Button(action: {
                            navigateToProfile = true
                        }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundColor(.neonGreen)
                                .padding(.top, 25)
                        }
                    }
                    .padding()
                    
                    // Signacer Logo
                    Image("SignacerLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 400, height: 100)
                        .clipped()
                    
                    // Profile Section
                    VStack(spacing: 8) {
                        Image("Jaren")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 180, height: 180)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                        
                        Text("Jaren Moreland")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("@itvsjmoney")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical)
                    
                    // My Cards Header
                    Text("My Cards")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Athlete Cards Grid
                    LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                        ForEach(athleteCards) { card in
                            NavigationLink(destination: AthleteView(athlete: card.athlete)) {
                                AthleteCardView(card: card)
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Athlete Card Model
struct AthleteCard: Identifiable {
    let id = UUID()
    let athlete: Athlete
    let backgroundImage: String
    let rarity: String
}

// Athlete Card View
struct AthleteCardView: View {
    let card: AthleteCard
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background Image
            Image(card.backgroundImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 200, alignment: .top)
                .cornerRadius(10)
            
            // Overlay with name and rarity
            VStack(alignment: .leading) {
                Text(card.athlete.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(card.rarity)
                    .font(.subheadline)
                    .foregroundColor(.neonGreen)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
        }
        .shadow(radius: 5)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

// Helper extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
} 
