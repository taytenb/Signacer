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
        
        // Create athlete data - Anthony Edwards
        let athleteData: [String: Any] = [
            "name": "Anthony Edwards",
            "profilePicURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntCard.jpg?alt=media&token=8507232e-4d44-4a18-9d1c-1e924a1f30ca",
            "highlightVideoURL": "AntGIF",
            "contentURL": "https://www.instagram.com/theanthonyedwards_/",
            "backgroundImage": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntPic.jpeg?alt=media&token=b317ffd8-3d34-4623-afbd-d31825d70fe7",
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
            
            // Add perks subcollection (Official Brand Sponsors)
            let perksCollection = athleteRef.collection("perks")
            
            let perk1Data: [String: Any] = [
                "id": "perk1",
                "title": "5% off all Adidas products",
                "description": "Exclusive discount on all Adidas products including the AE2 signature line",
                "link": "https://www.adidas.com/anthony_edwards",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAdidas.png?alt=media&token=e59209fa-5c01-4d33-9510-1bc46b168b8d",
                "active": true
            ]
            
            let perk2Data: [String: Any] = [
                "id": "perk2",
                "title": "$50 off select Prada items",
                "description": "Cardholders get exclusive access to Prada x Anthony Edwards collection with special pricing",
                "link": "https://www.prada.com/special_access",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-app.appspot.com/o/brands%2Fprada.jpg?alt=media",
                "active": true
            ]
            
            let perk3Data: [String: Any] = [
                "id": "perk3",
                "title": "Free Bose QuietComfort Earbuds with $300 purchase",
                "description": "Get Anthony's favorite Bose earbuds free with qualifying purchase",
                "link": "https://www.bose.com/nba_promo",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fbose.jpeg?alt=media&token=3c6ec1f0-e071-4e0e-8f68-700b75d95dbe",
                "active": true
            ]
            
            let perk4Data: [String: Any] = [
                "id": "perk4",
                "title": "Free Sprite with any Chipotle purchase",
                "description": "Anthony's game day meal - show your card for a free Sprite with any Chipotle purchase",
                "link": "https://www.chipotle.com/rewards",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2Fchipotle.png?alt=media&token=947ff123-ecc2-4aaa-9bcd-7fb7fc8b79ec",
                "active": true
            ]
            
            perksCollection.document("perk1").setData(perk1Data)
            perksCollection.document("perk2").setData(perk2Data)
            perksCollection.document("perk3").setData(perk3Data)
            perksCollection.document("perk4").setData(perk4Data)
            
            // Add events subcollection
            let eventsCollection = athleteRef.collection("events")
            
            let event1Data: [String: Any] = [
                "id": "event1",
                "title": "AE2 Signature Shoe Release Party",
                "description": "Be among the first to see and try on Anthony's new signature shoe with Adidas. Exclusive meet and greet opportunity with Anthony at the Minneapolis Adidas flagship store.",
                "date": Timestamp(date: Date().addingTimeInterval(30*24*60*60)),
                "location": "Adidas Store, Mall of America, Minneapolis",
                "maxGuests": 100,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntShoe.jpeg?alt=media&token=a2fc4fc8-6c58-4ae4-bba7-1ed878fd1688",
                "active": true
            ]
            
            let event2Data: [String: Any] = [
                "id": "event2",
                "title": "VIP Arena & Locker Room Tour",
                "description": "Exclusive behind-the-scenes tour of Target Center, including locker room access and on-court time before a Timberwolves game. Photo opportunity with Anthony included.",
                "date": Timestamp(date: Date().addingTimeInterval(45*24*60*60)),
                "location": "Target Center, Minneapolis",
                "maxGuests": 20,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntArena.jpeg?alt=media&token=6ed8c81e-c6c5-4150-b724-3b18c312cdcd",
                "active": true
            ]
            
            let event3Data: [String: Any] = [
                "id": "event3",
                "title": "Press Conference Access",
                "description": "Join Anthony behind-the-scenes at a post-game press conference. Experience what it's like to be in the room with NBA media and gain insights into Anthony's game day preparation.",
                "date": Timestamp(date: Date().addingTimeInterval(60*24*60*60)),
                "location": "Target Center Media Room, Minneapolis",
                "maxGuests": 15,
                "currentGuests": 0,
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntBehind.jpeg?alt=media&token=c7edc242-e2c0-4fcb-8e3f-d387fd85b06b",
                "active": true
            ]

            
            
            eventsCollection.document("event1").setData(event1Data)
            eventsCollection.document("event2").setData(event2Data)
            eventsCollection.document("event3").setData(event3Data)

            // Add communities subcollection
            let communitiesCollection = athleteRef.collection("communities")
            
            let community1Data: [String: Any] = [
                "id": "community1",
                "title": "Private Instagram Channel",
                "description": "Exclusive access to Anthony's private Instagram channel with behind-the-scenes content, training footage, and personal moments you won't see anywhere else.",
                "link": "https://www.instagram.com/ae2_exclusive/",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntInsta.png?alt=media&token=5563b5c3-3217-415d-9f84-406463dfbabc",
                "active": true
            ]
            
            let community2Data: [String: Any] = [
                "id": "community2",
                "title": "YouTube 'First Look' Series",
                "description": "Early access to Anthony's YouTube content, including workout routines, game day preparations, and lifestyle vlogs. Available 48 hours before public release.",
                "link": "https://www.youtube.com/anthonyedwards_exclusive",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntYoutube.jpeg?alt=media&token=e5f643ad-099c-4b18-81a3-7e637f0c9bb6",
                "active": true
            ]
            
            communitiesCollection.document("community1").setData(community1Data)
            communitiesCollection.document("community2").setData(community2Data)
            
            // Add giveaways subcollection
            let giveawaysCollection = athleteRef.collection("giveaways")
            
            let giveaway1Data: [String: Any] = [
                "id": "giveaway1",
                "title": "Appear in an Adidas Commercial",
                "description": "One lucky fan will get the chance to appear alongside Anthony in an upcoming Adidas commercial. Filming in Minneapolis with all expenses paid.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntComercial.jpeg?alt=media&token=e6b91e1f-efb4-43a2-9c60-6e13dc0f6f4f",
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(90*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            let giveaway2Data: [String: Any] = [
                "id": "giveaway2",
                "title": "Playoff Game Tickets",
                "description": "Win two VIP tickets to a Timberwolves playoff game, including pre-game tunnel access and commemorative merchandise package.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntTickets.jpeg?alt=media&token=2f7074d8-8924-48f4-a579-5ae7411aa945",
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(60*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            let giveaway3Data: [String: Any] = [
                "id": "giveaway3",
                "title": "Train One-on-One with Anthony",
                "description": "A once-in-a-lifetime opportunity to train with Anthony Edwards for a full day. Includes personal shooting and skills session, lunch, and a personalized training plan.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAnt1on1.jpeg?alt=media&token=9e4ac80d-e79b-479f-9603-a2d3171a636d",
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(120*24*60*60)),
                "active": true,
                "totalEntries": 0
            ]
            
            let giveaway4Data: [String: Any] = [
                "id": "giveaway4",
                "title": "Free Bose Headphones",
                "description": "Five lucky winners will receive Anthony's custom Bose QuietComfort Ultra headphones with special AE2 branding and autograph.",
                "imageURL": "https://firebasestorage.googleapis.com/v0/b/signacer-5a324.firebasestorage.app/o/app_assets%2FAntBoseEvent.jpeg?alt=media&token=ef35279c-c358-4e6a-98ad-3b3c63c0e572",
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
                "question": "Which Shoe Should I Wear for the Game?",
                "options": ["Green", "Blue", "White"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(7*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            let poll2Data: [String: Any] = [
                "id": "poll2",
                "question": "What trick should I do for my next dunk?",
                "options": ["360 Windmill", "Between the Legs", "Off the Backboard"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(14*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            let poll3Data: [String: Any] = [
                "id": "poll3",
                "question": "What should be my next YouTube video?",
                "options": ["Game Day Routine", "Home Workout", "Shopping Spree", "Day in the Life"],
                "startDate": now,
                "endDate": Timestamp(date: Date().addingTimeInterval(10*24*60*60)),
                "active": true,
                "totalVotes": 0
            ]
            
            pollsCollection.document("poll1").setData(poll1Data)
            pollsCollection.document("poll2").setData(poll2Data)
            pollsCollection.document("poll3").setData(poll3Data)
            
            // Create the results documents for the polls
            let results1Data: [String: Any] = [
                "optionCounts": [
                    "0": 0,
                    "1": 0,
                    "2": 0
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
                    "2": 0,
                    "3": 0
                ]
            ]
            
            pollsCollection.document("poll1").collection("results").document("counts").setData(results1Data)
            pollsCollection.document("poll2").collection("results").document("counts").setData(results2Data)
            pollsCollection.document("poll3").collection("results").document("counts").setData(results3Data)
            
            // Success
            self.athleteAddedMessage = "Athlete 'Anthony Edwards' added successfully with all data!"
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