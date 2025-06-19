import SwiftUI
import Firebase
import FirebaseFirestore

struct AdminView: View {
    @State private var testResults = ""
    @State private var athletes: [Athlete] = []
    @State private var selectedAthlete: Athlete? = nil
    @State private var showingAthleteDetail = false
    @State private var isAddingAthlete = false
    @State private var athleteAddedMessage = ""
    
    var body: some View {
        VStack {
            Button("Add Hardcoded Athlete") {
                addHardcodedAthlete()
            }
            .padding()
            .disabled(isAddingAthlete)
            
            if isAddingAthlete {
                ProgressView("Adding athlete...")
                    .padding()
            }
            
            if !athleteAddedMessage.isEmpty {
                Text(athleteAddedMessage)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Button("Load Athletes") {
                loadAthletes()
            }
            .padding()
            
            if !athletes.isEmpty {
                List(athletes) { athlete in
                    Button(action: {
                        selectedAthlete = athlete
                        showingAthleteDetail = true
                    }) {
                        Text(athlete.name)
                    }
                }
                .frame(height: 200)
            }
            
            if !testResults.isEmpty {
                ScrollView {
                    Text(testResults)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                }
                .frame(height: 300)
                .padding()
            }
        }
        .sheet(isPresented: $showingAthleteDetail, content: {
            if let athlete = selectedAthlete {
                AthleteDetailView(athlete: athlete)
            }
        })
    }
    
    private func addHardcodedAthlete() {
        isAddingAthlete = true
        athleteAddedMessage = ""
        
        let db = Firestore.firestore()
        // Generate a unique ID for the new athlete
        let athleteRef = db.collection("athletes").document()
        let athleteId = athleteRef.documentID
        
        // Current timestamp
        let now = Timestamp(date: Date())
        
        // Create athlete data - RDC Group
        let athleteData: [String: Any] = [
            "username": "rdcgroup",
            "name": "RDC Group",
            "profilePicURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20cover.jfif?alt=media&token=a1a1d06c-bb53-4362-9ab1-2f9f70314198", // Will be updated manually
            "highlightVideoURL": "RDCGIF",
            "contentURL": "https://www.youtube.com/@RDCworld1",
            "backgroundImage": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20cover.jfif?alt=media&token=a1a1d06c-bb53-4362-9ab1-2f9f70314198", // Will be updated manually
            "createdAt": now,
            "updatedAt": now
        ]
        
        // Save to Firestore
        athleteRef.setData(athleteData) { error in
            if let error = error {
                self.testResults = "Error adding athlete: \(error.localizedDescription)"
                self.isAddingAthlete = false
                return
            }
            
            // Add perks subcollection
            let perksCollection = athleteRef.collection("perks")
            
            let perk1Data: [String: Any] = [
                "id": "perk1",
                "title": "20% Off RDCWorld1 Merch",
                "description": "Get exclusive 20% discount on all RDCWorld1 merchandise throughout the year. Rock the same gear as your favorite content creators and show your RDC pride with premium apparel and accessories.",
                "link": "https://rdcworld1.com/shop",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20merch.jpg?alt=media&token=37b262ac-542e-4762-8586-d33cc288d600", // Will be updated manually
                "active": true
            ]
            
            let perk2Data: [String: Any] = [
                "id": "perk2",
                "title": "Early Access to DreamCon Tickets",
                "description": "Secure your spot at DreamCon before anyone else! Get exclusive early access to tickets in April, ensuring you don't miss out on the premier anime and gaming convention experience.",
                "link": "https://dreamcon.com",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fdream%20con.png?alt=media&token=21afb9cb-a656-4398-9f4b-7d8cc0bd91e5", // Will be updated manually
                "active": true
            ]
            
            let perk3Data: [String: Any] = [
                "id": "perk3",
                "title": "Discount on Manga/Anime Subscriptions",
                "description": "Enhanced viewing experience with discounted Crunchyroll subscriptions available June through August. Dive deeper into the anime world that inspires RDC's amazing content and skits.",
                "link": "https://www.crunchyroll.com",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fcrunchyroll.png?alt=media&token=74ceafc6-31ae-4e78-826d-65bcca04b4da", // Will be updated manually
                "active": true
            ]
            
            let perk4Data: [String: Any] = [
                "id": "perk4",
                "title": "Free Uber Eats Gold Membership",
                "description": "Enjoy complimentary Uber Eats Gold membership with free delivery, exclusive restaurant access, and special member deals. Fuel your anime marathons and gaming sessions like the RDC crew.",
                "link": "https://www.ubereats.com",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fuber%20eats.png?alt=media&token=27b00edd-304e-4161-a9e0-c11a3993be9c", // Will be updated manually
                "active": true
            ]
            
            let perk5Data: [String: Any] = [
                "id": "perk5",
                "title": "Exclusive Access to RDC Skit Drafts",
                "description": "Get behind-the-scenes access to RDC skit drafts and concepts in monthly rotations from January through December. See the creative process before the final videos drop and influence future content.",
                "link": "https://www.youtube.com/@RDCworld1",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20skit.jpg?alt=media&token=ae451d2f-1fe1-47b4-a7dd-7d87e9d474be", // Will be updated manually
                "active": true
            ]
            
            let perk6Data: [String: Any] = [
                "id": "perk6",
                "title": "First Access to RDC Game Nights Sign-Ups",
                "description": "Priority access to RDC gaming events happening in March, July, and November. Join the crew for epic gaming sessions and be part of the content that millions of fans love to watch.",
                "link": "https://discord.gg/rdcgaming",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fgame%20night.jpg?alt=media&token=e917ed91-0052-4714-8096-13efca2f5ff8", // Will be updated manually
                "active": true
            ]
            
            perksCollection.document("perk1").setData(perk1Data)
            perksCollection.document("perk2").setData(perk2Data)
            perksCollection.document("perk3").setData(perk3Data)
            perksCollection.document("perk4").setData(perk4Data)
            perksCollection.document("perk5").setData(perk5Data)
            perksCollection.document("perk6").setData(perk6Data)
            
            // Add events subcollection
            let eventsCollection = athleteRef.collection("events")
            
            let event1Data: [String: Any] = [
                "id": "event1",
                "title": "RDC Virtual Anime Debate Night",
                "description": "Join RDC for an epic virtual anime debate night featuring live Zoom interaction and real-time chat. Defend your favorite anime, participate in trivia, and engage with the RDC crew in heated discussions about the best shows and characters.",
                "date": Timestamp(date: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 15)) ?? Date()),
                "location": "Virtual Event - Zoom + Live Chat",
                "maxGuests": 100,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fanime%20skit.jpg?alt=media&token=f004c550-4ac5-4931-8576-e9a50ec9c9db", // Will be updated manually
                "active": true
            ]
            
            let event2Data: [String: Any] = [
                "id": "event2",
                "title": "Exclusive DreamCon Meet-Up for Cardholders",
                "description": "Connect with fellow RDC fans at an exclusive cardholders-only meet-up during DreamCon. Meet the RDC crew in person, get exclusive merchandise, photo opportunities, and insider access to convention activities.",
                "date": Timestamp(date: Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 20)) ?? Date()),
                "location": "DreamCon Convention Center",
                "maxGuests": 50,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fdream%20con.png?alt=media&token=21afb9cb-a656-4398-9f4b-7d8cc0bd91e5", // Will be updated manually
                "active": true
            ]
            
            let event3Data: [String: Any] = [
                "id": "event3",
                "title": "RDC Gaming Tournament",
                "description": "Compete in the ultimate RDC gaming tournament streamed live on Twitch with Discord coordination. Battle against other cardholders and potentially face off against RDC members themselves in various gaming challenges.",
                "date": Timestamp(date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10)) ?? Date()),
                "location": "Virtual Event - Twitch/Discord",
                "maxGuests": 64,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fgaming%20tourney.webp?alt=media&token=9259ae27-6749-4265-943b-7bfce45e1066", // Will be updated manually
                "active": true
            ]
            
            let event4Data: [String: Any] = [
                "id": "event4",
                "title": "Year-End Recap Stream + Fan AMA",
                "description": "Close out the year with RDC's exclusive year-end recap stream featuring a comprehensive fan AMA session. Ask burning questions, relive the best moments, and get insights into what's coming next year.",
                "date": Timestamp(date: Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 20)) ?? Date()),
                "location": "Virtual Event - Live Stream",
                "maxGuests": 200,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20podcast.jpg?alt=media&token=3f5eaa79-6dc0-4a71-a096-55342d035700", // Will be updated manually
                "active": true
            ]
            
            eventsCollection.document("event1").setData(event1Data)
            eventsCollection.document("event2").setData(event2Data)
            eventsCollection.document("event3").setData(event3Data)
            eventsCollection.document("event4").setData(event4Data)

            // Add communities subcollection
            let communitiesCollection = athleteRef.collection("communities")
            
            let community1Data: [String: Any] = [
                "id": "community1",
                "title": "Private RDC Instagram Channel",
                "description": "Get exclusive access to RDC's private Instagram channel featuring behind-the-scenes content, livestream alerts, Q&A sessions, and personal moments with the crew that aren't available to the general public.",
                "link": "https://www.instagram.com/rdcprivate",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntInsta.png?alt=media&token=5563b5c3-3217-415d-9f84-406463dfbabc", // Will be updated manually
                "active": true
            ]
            
            let community2Data: [String: Any] = [
                "id": "community2",
                "title": "Discord Fan Hub",
                "description": "Join the exclusive Discord channel designed specifically for Signacer cardholders. Participate in member Q&As, get sneak peeks of upcoming content, early access to content drops, and direct communication with RDC members.",
                "link": "https://discord.gg/rdcfanhub",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FDiscord.jpg?alt=media&token=6e499908-1b1f-41ef-8f8c-a6f018f55b64", // Will be updated manually
                "active": true
            ]
            
            communitiesCollection.document("community1").setData(community1Data)
            communitiesCollection.document("community2").setData(community2Data)
            
            // Add giveaways subcollection
            let giveawaysCollection = athleteRef.collection("giveaways")
            
            let giveaway1Data: [String: Any] = [
                "id": "giveaway1",
                "title": "DreamCon VIP Package Giveaway",
                "description": "Win the ultimate DreamCon experience in March including round-trip flight, hotel accommodation, and exclusive VIP badge with premium access to all convention activities and meet-and-greets.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fdream%20con.png?alt=media&token=21afb9cb-a656-4398-9f4b-7d8cc0bd91e5", // Will be updated manually
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(60*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            let giveaway2Data: [String: Any] = [
                "id": "giveaway2",
                "title": "RDC Podcast Guest Spot",
                "description": "Become an exclusive guest on RDC's 'Back and Forth' podcast episode. Share your thoughts, participate in discussions, and become part of RDC history as a featured guest on their popular show.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20podcast.jpg?alt=media&token=3f5eaa79-6dc0-4a71-a096-55342d035700", // Will be updated manually
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(90*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            let giveaway3Data: [String: Any] = [
                "id": "giveaway3",
                "title": "Custom RDC-Themed Gaming Console",
                "description": "Win a custom RDC-themed gaming console (Xbox or PS5 - fan vote decides) in September. This one-of-a-kind console features exclusive RDC artwork and comes with premium gaming accessories.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fps5.png?alt=media&token=fc4047d2-c605-4c77-85b0-80b914457024", // Will be updated manually
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(120*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            let giveaway4Data: [String: Any] = [
                "id": "giveaway4",
                "title": "Cameo in an RDC Skit",
                "description": "The ultimate prize - get flown out to Atlanta in November and featured in an official RDC skit video. Work alongside the crew, be part of their creative process, and appear in content watched by millions.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Frdc%20skit.jpg?alt=media&token=ae451d2f-1fe1-47b4-a7dd-7d87e9d474be", // Will be updated manually
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(45*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            giveawaysCollection.document("giveaway1").setData(giveaway1Data)
            giveawaysCollection.document("giveaway2").setData(giveaway2Data)
            giveawaysCollection.document("giveaway3").setData(giveaway3Data)
            giveawaysCollection.document("giveaway4").setData(giveaway4Data)
            
            // Add polls subcollection
            let pollsCollection = athleteRef.collection("polls")
            
            let poll1Data: [String: Any] = [
                "id": "poll1",
                "question": "Pick the Next RDC Skit Theme",
                "options": ["Superheroes", "Gaming", "School Life", "Sports"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(7*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            let poll2Data: [String: Any] = [
                "id": "poll2",
                "question": "Who Should Be a Guest Star in Our Next Video?",
                "options": ["Cash Nasty", "Kai Cenat", "Agent 00"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(14*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            let poll3Data: [String: Any] = [
                "id": "poll3",
                "question": "Which anime should RDC review next?",
                "options": ["Attack on Titan", "Demon Slayer", "Jujutsu Kaisen"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(10*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            let poll4Data: [String: Any] = [
                "id": "poll4",
                "question": "What gaming content should we focus on?",
                "options": ["Fighting Games", "Battle Royale", "Sports Games"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(12*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            pollsCollection.document("poll1").setData(poll1Data)
            pollsCollection.document("poll2").setData(poll2Data)
            pollsCollection.document("poll3").setData(poll3Data)
            pollsCollection.document("poll4").setData(poll4Data)
            
            // Create the results documents for the polls
            let results1Data: [String: Any] = [
                "optionCounts": [
                    "0": 0,
                    "1": 0,
                    "2": 0,
                    "3": 0
                ]
            ]
            
            let results2Data: [String: Any] = [
                "optionCounts": [
                    "0": 0,
                    "1": 0,
                    "2": 0
                ]
            ]
            
            let results3Data: [String: Any] = [
                "optionCounts": [
                    "0": 0,
                    "1": 0,
                    "2": 0
                ]
            ]
            
            let results4Data: [String: Any] = [
                "optionCounts": [
                    "0": 0,
                    "1": 0,
                    "2": 0
                ]
            ]
            
            pollsCollection.document("poll1").collection("results").document("counts").setData(results1Data)
            pollsCollection.document("poll2").collection("results").document("counts").setData(results2Data)
            pollsCollection.document("poll3").collection("results").document("counts").setData(results3Data)
            pollsCollection.document("poll4").collection("results").document("counts").setData(results4Data)
            
            // Success
            self.athleteAddedMessage = "Athlete 'RDC Group' added successfully with all data!"
            self.isAddingAthlete = false
            
            // Reload athletes list
            self.loadAthletes()
        }
    }
    
    func loadAthletes() {
        let db = Firestore.firestore()
        db.collection("athletes").getDocuments { snapshot, error in
            if let error = error {
                testResults = "Error loading athletes: \(error.localizedDescription)"
                return
            }
            
            guard let documents = snapshot?.documents else {
                testResults = "No athletes found"
                return
            }
            
            var loadedAthletes: [Athlete] = []
            let group = DispatchGroup()
            
            for document in documents {
                group.enter()
                let athleteId = document.documentID
                FirestoreManager.shared.fetchAthlete(athleteId: athleteId) { athlete in
                    if let athlete = athlete {
                        loadedAthletes.append(athlete)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.athletes = loadedAthletes
                self.testResults = "Loaded \(loadedAthletes.count) athletes"
            }
        }
    }
    
    func checkSubcollection(athleteId: String, subcollection: String) {
        let db = Firestore.firestore()
        let ref = db.collection("athletes").document(athleteId).collection(subcollection)
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                self.testResults += "Error getting \(subcollection): \(error.localizedDescription)\n"
                return
            }
            
            if let snapshot = snapshot {
                self.testResults += "Found \(snapshot.documents.count) \(subcollection)\n"
                
                // Print the first few items
                for (index, doc) in snapshot.documents.prefix(3).enumerated() {
                    let data = doc.data()
                    let title = data["title"] as? String ?? data["question"] as? String ?? "Unknown"
                    self.testResults += "  \(index+1). \(title)\n"
                }
            } else {
                self.testResults += "No \(subcollection) found or snapshot is nil\n"
            }
        }
    }
}

struct AthleteDetailView: View {
    let athlete: Athlete
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with athlete info
                AsyncImage(url: URL(string: athlete.profilePicURL)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(height: 200)
                .clipped()
                
                Text(athlete.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                // Perks section
                if !athlete.perks.isEmpty {
                    Section("Perks") {
                        ForEach(athlete.perks, id: \.id) { perk in
                            VStack(alignment: .leading) {
                                Text(perk.title)
                                    .font(.headline)
                                AsyncImage(url: URL(string: perk.imageURL)) { image in
                                    image.resizable().aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(height: 100)
                                .cornerRadius(8)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                
                // Events section
                if !athlete.events.isEmpty {
                    Section("Events") {
                        ForEach(athlete.events, id: \.id) { event in
                            VStack(alignment: .leading) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.description)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                if let date = event.date {
                                    Text(date, style: .date)
                                }
                                Text(event.location)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                
                // Continue with sections for communities, giveaways, polls
                // Add more sections as needed
            }
            .padding()
        }
    }
}

// Data structure for athlete form
struct AthleteFormData {
    var name: String = ""
    var profilePicURL: String = ""
    var highlightVideoURL: String = ""
    var contentURL: String = ""
    var backgroundImage: String = ""
}
