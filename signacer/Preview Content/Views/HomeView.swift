import SwiftUI

struct HomeView: View {
    @State private var navigateToProfile = false
    // Assuming you store the username in UserDefaults during onboarding
    private var username: String {
        UserDefaults.standard.string(forKey: "username") ?? "User"
    }
    
    
    // Updated athlete cards array with both athletes
    private let athleteCards: [AthleteCard] = [
        // Justin Jefferson Card
        AthleteCard(
            athlete: Athlete(
                id: "athlete1",
                name: "Justin Jefferson",
                profilePicURL: "AthleteJJ",
                highlightVideoURL: "JJGIF",
                perks: [
                    Perk(id: "perk1", title: "15% off Amazon", link: "https://amazon.com", imageURL: "Amazon"),
                    Perk(id: "perk2", title: "10% off Gatorade", link: "https://gatorade.com", imageURL: "Gatorade"),
                    Perk(id: "perk3", title: "5% off Under Armor", link: "https://underarmour.com", imageURL: "Underarmour"),
                    Perk(id: "perk4", title: "Oakley Discount", link: "https://www.oakley.com", imageURL: "Oakley")
                ],
                events: [
                    Event(
                        id: "event1",
                        title: "Justin Jefferson Pop-Up Event",
                        description: "Meet Justin at a special brand pop-up event",
                        date: Date().addingTimeInterval(14*24*60*60),
                        location: "Minneapolis, MN",
                        maxGuests: 100,
                        isRSVPed: false,
                        imageURL: "PopupEventJJ"
                    ),
                    Event(
                        id: "event2",
                        title: "7-on-7 Tournament by Jettas",
                        description: "Join Justin's tournament for young athletes",
                        date: Date().addingTimeInterval(30*24*60*60),
                        location: "US Bank Stadium",
                        maxGuests: 200,
                        isRSVPed: false,
                        imageURL: "JJ7on7"
                    ),
                    Event(
                        id: "event3",
                        title: "Zoom Q&A Session",
                        description: "Virtual Q&A with Justin Jefferson",
                        date: Date().addingTimeInterval(7*24*60*60),
                        location: "Online",
                        maxGuests: 500,
                        isRSVPed: false,
                        imageURL: "zoom"
                    )
                ],
                communities: [
                    Community(id: "comm1", title: "Discord Community", link: "https://discord.com", imageURL: "Discord"),
                    Community(id: "comm2", title: "Social Impact Initiative", link: "https://charity.org", imageURL: "Charity")
                ],
                giveaways: [
                    Giveaway(
                        id: "give1",
                        title: "Signed Game Item",
                        description: "Win a signed item from every game ($5 entry)",
                        imageURL: "auto",
                        endDate: Date().addingTimeInterval(90*24*60*60),
                        isEntered: false
                    ),
                    Giveaway(
                        id: "give2",
                        title: "Game Ticket Giveaway",
                        description: "Win tickets to an upcoming Vikings game",
                        imageURL: "tickets",
                        endDate: Date().addingTimeInterval(45*24*60*60),
                        isEntered: false
                    ),
                    Giveaway(
                        id: "give3",
                        title: "Brand Gift Bag",
                        description: "Win Under Armour shoes, Oakley glasses, and more",
                        imageURL: "cleats white",
                        endDate: Date().addingTimeInterval(60*24*60*60),
                        isEntered: false
                    )
                ],
                contentURL: "https://youtube.com",
                polls: [
                    Poll(
                        id: "poll1",
                        question: "What cleats should I wear?",
                        options: ["Purple", "White", "Yellow"],
                        endDate: Date().addingTimeInterval(3*24*60*60)
                    )
                ]
            ),
            backgroundImage: "JustinJefferson",
            rarity: "1/100"
        ),
        
        // Sean O'Malley Card
        AthleteCard(
            athlete: Athlete(
                id: "athlete2",
                name: "Sean O'Malley",
                profilePicURL: "SeanOMalley",
                highlightVideoURL: "SeanGIF",
                perks: [
                    Perk(id: "perk1", title: "PrizePicks – Free $20 for New Sign-Up", link: "https://prizepicks.com", imageURL: "PrizePicks"),
                    Perk(id: "perk2", title: "RYSE – First Protein Powder Free & 20% off bundles", link: "https://rysesupps.com", imageURL: "RYSE"),
                    Perk(id: "perk3", title: "YoungLA – Buy 1, Get 1 Free on shirts", link: "https://youngla.com", imageURL: "YoungLA"),
                    Perk(id: "perk4", title: "Sanabul – 25% off", link: "https://sanabul.com", imageURL: "Sanabul"),
                    Perk(id: "perk5", title: "Happy Dad – 15% off & Free Hat", link: "https://happydad.com", imageURL: "HappyDad"),
                    Perk(id: "perk6", title: "W – Free First Bundle & 10% off", link: "https://w.com", imageURL: "WBrand")
                ],
                events: [
                    Event(
                        id: "event1",
                        title: "Jobin Zoom Q&A",
                        description: "Virtual Q&A session with Sean",
                        date: Date().addingTimeInterval(10*24*60*60),
                        location: "Online",
                        maxGuests: 300,
                        isRSVPed: false,
                        imageURL: "zoom"
                    ),
                    Event(
                        id: "event2",
                        title: "Jobin MMA Crash Course",
                        description: "Learn MMA basics with Sean",
                        date: Date().addingTimeInterval(21*24*60*60),
                        location: "Las Vegas, NV",
                        maxGuests: 50,
                        isRSVPed: false,
                        imageURL: "MMAClass"
                    ),
                    Event(
                        id: "event3",
                        title: "Jobin Pop-Up with Brand Shop",
                        description: "Meet Sean and shop exclusive merch",
                        date: Date().addingTimeInterval(35*24*60*60),
                        location: "Phoenix, AZ",
                        maxGuests: 150,
                        isRSVPed: false,
                        imageURL: "SeanPopup"
                    )
                ],
                communities: [
                    Community(id: "comm1", title: "Patreon Community", link: "https://patreon.com", imageURL: "Patreon")
                ],
                giveaways: [
                    Giveaway(
                        id: "give1",
                        title: "UFC Tickets Experience",
                        description: "Win tickets to an upcoming UFC event",
                        imageURL: "UFCTickets",
                        endDate: Date().addingTimeInterval(60*24*60*60),
                        isEntered: false
                    ),
                    Giveaway(
                        id: "give2",
                        title: "Weekend with Suga Show",
                        description: "Spend a weekend with Sean and the RHH Pod team",
                        imageURL: "SugaWeekend",
                        endDate: Date().addingTimeInterval(90*24*60*60),
                        isEntered: false
                    ),
                    Giveaway(
                        id: "give3",
                        title: "Cold Plunge",
                        description: "Win a premium cold plunge tub",
                        imageURL: "ColdPlunge",
                        endDate: Date().addingTimeInterval(45*24*60*60),
                        isEntered: false
                    )
                ],
                contentURL: "https://youtube.com",
                polls: [
                    Poll(
                        id: "poll1",
                        question: "What color shorts should I wear for the next fight?",
                        options: ["Pink", "Red", "Blue", "Black"],
                        endDate: Date().addingTimeInterval(14*24*60*60)
                    ),
                    Poll(
                        id: "poll2",
                        question: "Who should I fight next?",
                        options: ["Merab", "Petr Yan", "Umar"],
                        endDate: Date().addingTimeInterval(30*24*60*60)
                    )
                ]
            ),
            backgroundImage: "SeanOMalley",
            rarity: "1/50"
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Picture and Navigation
                    HStack {
                        Spacer()
                        
                        NavigationLink(destination: ProfileView(), isActive: $navigateToProfile) {
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
                    }
                    .padding()
                    .zIndex(100) // Ensure it's above other elements
                    
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
                        
                        // Add the bio text here
//                        Text("Book lover, sports fanatic, and lifelong fan of The Weeknd. Whether I'm diving into a great novel, catching the latest game, or vibing to XO classics, I'm all about passion and community.")
//                            .font(.body)
//                            .foregroundColor(.white)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 20)
//                            .padding(.top, 8)
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

