import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct HomeView: View {
    @State private var navigateToProfile = false
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
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
                        ZStack(alignment: .bottomTrailing) {
                            // Profile image
                            if let user = authViewModel.user, !user.profilePicURL.isEmpty {
                                if user.profilePicURL.starts(with: "http") {
                                    // Remote image
                                    AsyncImage(url: URL(string: user.profilePicURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 180, height: 180)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 180, height: 180)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                        case .failure:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 180, height: 180)
                                                .foregroundColor(.neonGreen)
                                                .background(Color.black)
                                                .clipShape(Circle())
                                                .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                        @unknown default:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .frame(width: 180, height: 180)
                                                .foregroundColor(.neonGreen)
                                        }
                                    }
                                } else {
                                    // Local image
                                    Image(user.profilePicURL)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 180, height: 180)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 180, height: 180)
                                    .foregroundColor(.neonGreen)
                                    .background(Color.black)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.neonGreen, lineWidth: 2))
                            }
                            
                            // Edit button overlay
                            NavigationLink(destination: EditProfileView()) {
                                ZStack {
                                    Circle()
                                        .fill(Color.neonGreen)
                                        .frame(width: 50, height: 50)
                                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                                    
                                    Image(systemName: "pencil")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        
                        Text(authViewModel.user?.firstName ?? "User")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        
                        
                        Text("@\(authViewModel.user?.username ?? "user")")
                            .font(.title2)
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
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                            .scaleEffect(1.5)
                            .padding()
                    } else if let error = viewModel.error {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                                .padding()
                            
                            Text("Error loading cards: \(error)")
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Try Again") {
                                viewModel.fetchUserCards()
                            }
                            .padding()
                            .background(Color.neonGreen)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                        .padding()
                    } else if viewModel.athleteCards.isEmpty {
                        VStack {
                            Image(systemName: "creditcard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .padding()
                            
                            Text("You don't have any cards yet.")
                                .foregroundColor(.white)
                                .padding()
                            
                            // In a real app, you might add a button to get cards
                            Button("Scan a Card") {
                                // This would be implemented to handle scanning QR codes
                                // or some other way to acquire cards
                            }
                            .padding()
                            .background(Color.neonGreen)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                        .padding()
                    } else {
                        // Athlete Cards Grid
                        LazyVGrid(columns: [GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.athleteCards) { card in
                                NavigationLink(destination: AthleteView(athlete: card.athlete)) {
                                    AthleteCardView(card: card)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchUserCards()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

class HomeViewModel: ObservableObject {
    @Published var athleteCards: [AthleteCard] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    func fetchUserCards() {
        isLoading = true
        error = nil
        
        // ONLY fetch all athletes from the athletes collection
        let db = Firestore.firestore()
        db.collection("athletes").getDocuments { [weak self] snapshot, error in
            if let error = error {
                self?.isLoading = false
                self?.error = error.localizedDescription
                print("Firestore error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                self?.isLoading = false
                print("No athletes found or snapshot is nil")
                // If no athletes found, fall back to mock data
                self?.athleteCards = self?.mockAthleteCards().sorted(by: { $0.athlete.name < $1.athlete.name }) ?? []
                return
            }
            
            print("Found \(documents.count) athlete documents")
            var cards: [AthleteCard] = []
            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                let athleteId = document.documentID
                let data = document.data()
                let name = data["name"] as? String ?? "Unknown Athlete"
                let profilePicURL = data["profilePicURL"] as? String ?? ""
                let highlightVideoURL = data["highlightVideoURL"] as? String ?? ""
                let contentURL = data["contentURL"] as? String ?? ""
                let backgroundImage = data["backgroundImage"] as? String ?? ""
                
                // Create a simple athlete directly from document data
                FirestoreManager.shared.fetchAthlete(athleteId: athleteId) { athlete in
                    if let athlete = athlete {
                        let card = AthleteCard(
                            athlete: athlete,
                            backgroundImage: backgroundImage,
                            rarity: "1/100"
                        )
                        cards.append(card)
                        print("Added card for: \(athlete.name)")
                    } else {
                        print("Failed to fetch athlete data for ID: \(athleteId)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self?.isLoading = false
                // Sort cards alphabetically by athlete name
                self?.athleteCards = cards.sorted(by: { $0.athlete.name < $1.athlete.name })
                print("Loaded \(cards.count) athlete cards")
                
                // If no cards found, use mock data as fallback
                if cards.isEmpty {
                    print("No athletes found, using mock data")
                    self?.athleteCards = self?.mockAthleteCards().sorted(by: { $0.athlete.name < $1.athlete.name }) ?? []
                }
            }
        }
    }
    
    // Mock data for preview and new users
    private func mockAthleteCards() -> [AthleteCard] {
        return [
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
            // Background Image - handle both local and remote URLs
            if card.backgroundImage.starts(with: "http") {
                // Remote image
                AsyncImage(url: URL(string: card.backgroundImage)) { phase in
                    switch phase {
                    case .empty:
                        Color.gray
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Color.gray.overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white)
                        )
                    @unknown default:
                        Color.gray
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200, alignment: .top)
                .cornerRadius(10)
            } else {
                // Local image
                Image(card.backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200, alignment: .top)
                    .cornerRadius(10)
            }
            
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

