import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    // MARK: - User Methods
    
    func createUser(user: User, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let userData: [String: Any] = [
            "uid": uid,
            "email": user.email,
            "username": user.username,
            "profilePicURL": user.profilePicURL,
            "age": user.age,
            "phoneNumber": user.phoneNumber,
            "bio": user.bio
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            completion(error == nil)
        }
    }
    
    func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                let user = User(
                    uid: userId,
                    email: data["email"] as? String ?? "",
                    username: data["username"] as? String ?? "",
                    firstName: data["firstName"] as? String ?? "",
                    lastName: data["lastName"] as? String ?? "",
                    profilePicURL: data["profilePicURL"] as? String ?? "",
                    age: data["age"] as? Int ?? 0,
                    phoneNumber: data["phoneNumber"] as? String ?? "",
                    bio: data["bio"] as? String ?? ""
                )
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Athlete Methods
    
    func fetchAllAthletes(completion: @escaping ([Athlete]) -> Void) {
        db.collection("athletes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching athletes: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            var athletes: [Athlete] = []
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let athleteId = document.documentID
                self.fetchAthlete(athleteId: athleteId) { athlete in
                    if let athlete = athlete {
                        athletes.append(athlete)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(athletes)
            }
        }
    }
    
    func fetchAthlete(athleteId: String, completion: @escaping (Athlete?) -> Void) {
        let athleteRef = db.collection("athletes").document(athleteId)
        
        athleteRef.getDocument { document, error in
            if let error = error {
                print("Error fetching athlete: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                completion(nil)
                return
            }
            
            let dispatchGroup = DispatchGroup()
            
            var perks: [Perk] = []
            var events: [Event] = []
            var communities: [Community] = []
            var giveaways: [Giveaway] = []
            var polls: [Poll] = []
            
            // Fetch perks
            dispatchGroup.enter()
            athleteRef.collection("perks").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let perk = Perk(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            link: data["link"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? ""
                        )
                        perks.append(perk)
                    }
                }
                dispatchGroup.leave()
            }
            
            // Fetch events
            dispatchGroup.enter()
            athleteRef.collection("events").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let event = Event(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            date: (data["date"] as? Timestamp)?.dateValue(),
                            location: data["location"] as? String ?? "",
                            maxGuests: data["maxGuests"] as? Int ?? 0,
                            isRSVPed: false, // Will be updated later
                            imageURL: data["imageURL"] as? String ?? ""
                        )
                        events.append(event)
                    }
                }
                dispatchGroup.leave()
            }
            
            // Fetch communities
            dispatchGroup.enter()
            athleteRef.collection("communities").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let community = Community(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            link: data["link"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? ""
                        )
                        communities.append(community)
                    }
                }
                dispatchGroup.leave()
            }
            
            // Fetch giveaways
            dispatchGroup.enter()
            athleteRef.collection("giveaways").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let giveaway = Giveaway(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? "",
                            endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                            isEntered: false // Will be updated later
                        )
                        giveaways.append(giveaway)
                    }
                }
                dispatchGroup.leave()
            }
            
            // Fetch polls
            dispatchGroup.enter()
            athleteRef.collection("polls").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let poll = Poll(
                            id: doc.documentID,
                            question: data["question"] as? String ?? "",
                            options: data["options"] as? [String] ?? [],
                            endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                        )
                        polls.append(poll)
                    }
                }
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                let athlete = Athlete(
                    id: athleteId,
                    name: data["name"] as? String ?? "",
                    profilePicURL: data["profilePicURL"] as? String ?? "",
                    highlightVideoURL: data["highlightVideoURL"] as? String ?? "",
                    perks: perks,
                    events: events,
                    communities: communities,
                    giveaways: giveaways,
                    contentURL: data["contentURL"] as? String ?? "",
                    polls: polls
                )
                completion(athlete)
            }
        }
    }
    
    // MARK: - User Cards Methods
    
    func addCardToUser(userId: String, cardId: String, athleteId: String, rarity: String, completion: @escaping (Bool) -> Void) {
        let cardData: [String: Any] = [
            "cardId": cardId,
            "athleteId": athleteId,
            "acquisitionDate": FieldValue.serverTimestamp(),
            "rarity": rarity
        ]
        
        db.collection("users").document(userId).collection("userCards").document(cardId).setData(cardData) { error in
            completion(error == nil)
        }
    }
    
    func fetchUserCards(userId: String, completion: @escaping ([AthleteCard]) -> Void) {
        db.collection("users").document(userId).collection("userCards").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user cards: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            
            var athleteCards: [AthleteCard] = []
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                dispatchGroup.enter()
                let data = document.data()
                let cardId = document.documentID
                let athleteId = data["athleteId"] as? String ?? ""
                let rarity = data["rarity"] as? String ?? ""
                
                self.fetchAthlete(athleteId: athleteId) { athlete in
                    if let athlete = athlete {
                        let card = AthleteCard(
                            athlete: athlete,
                            backgroundImage: athlete.profilePicURL, // Or fetch from cards collection
                            rarity: rarity
                        )
                        athleteCards.append(card)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(athleteCards)
            }
        }
    }
    
    // MARK: - Event Methods
    
    func rsvpToEvent(userId: String, athleteId: String, eventId: String, name: String, email: String, guests: Int, completion: @escaping (Bool) -> Void) {
        let rsvpData: [String: Any] = [
            "userId": userId,
            "name": name,
            "email": email,
            "numberOfGuests": guests,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("athletes").document(athleteId).collection("events").document(eventId).collection("rsvps").document(userId).setData(rsvpData) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Giveaway Methods
    
    func enterGiveaway(userId: String, athleteId: String, giveawayId: String, completion: @escaping (Bool) -> Void) {
        let entryData: [String: Any] = [
            "userId": userId,
            "entryDate": FieldValue.serverTimestamp()
        ]
        
        db.collection("athletes").document(athleteId).collection("giveaways").document(giveawayId).collection("entries").document(userId).setData(entryData) { error in
            completion(error == nil)
        }
    }
    
    // MARK: - Poll Methods
    
    func voteInPoll(userId: String, athleteId: String, pollId: String, selectedOption: String, completion: @escaping (Bool) -> Void) {
        let voteData: [String: Any] = [
            "userId": userId,
            "selectedOption": selectedOption,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("athletes").document(athleteId).collection("polls").document(pollId).collection("votes").document(userId).setData(voteData) { error in
            completion(error == nil)
        }
    }
}
