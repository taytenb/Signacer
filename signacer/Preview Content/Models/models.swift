import Foundation

struct User {
    let uid: String
    let email: String
    let username: String
    var firstName: String
    var lastName: String
    var profilePicURL: String
    var age: Int
    var phoneNumber: String
    var bio: String
    var howDidYouHearAboutUs: String
    
    // Add this computed property for safe username access
    var displayUsername: String {
        if !username.isEmpty {
            return username
        } else if !firstName.isEmpty {
            return firstName
        } else {
            return email.components(separatedBy: "@").first ?? "Anonymous"
        }
    }
    
    // Default initialization with empty values
    static func defaultUser(uid: String, email: String) -> User {
        return User(
            uid: uid,
            email: email,
            username: email.components(separatedBy: "@").first ?? "user",
            firstName: "",
            lastName: "",
            profilePicURL: "default_profile",
            age: 0,
            phoneNumber: "",
            bio: "",
            howDidYouHearAboutUs: ""
        )
    }
}

struct Athlete: Identifiable {
    let id: String
    let username: String
    let name: String
    let profilePicURL: String
    let highlightVideoURL: String
    let perks: [Perk]
    let events: [Event]
    let communities: [Community]
    let giveaways: [Giveaway]
    let contentURL: String
    let polls: [Poll]
}

struct Perk: Identifiable {
    let id: String
    let title: String
    let link: String
    let imageURL: String
}

struct Event: Identifiable {
    let id: String
    let title: String
    let description: String
    let date: Date?
    let location: String
    let maxGuests: Int
    var isRSVPed: Bool
    let imageURL: String
}

struct Community: Identifiable {
    let id: String
    let title: String
    let link: String
    let imageURL: String
}

struct Giveaway: Identifiable {
    let id: String
    let title: String
    let description: String
    let imageURL: String
    let endDate: Date
    var isEntered: Bool
}

struct Poll: Identifiable {
    let id: String
    let question: String
    let options: [String]
    let endDate: Date
    var selectedOption: String? = nil
}

// MARK: - Chat Models
enum MessageStatus: String, Codable {
    case sending = "sending"
    case sent = "sent"
    case failed = "failed"
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let athleteId: String
    let userId: String
    let username: String
    let message: String
    let timestamp: Date
    var isFromCurrentUser: Bool = false // This will be computed, not stored
    var status: MessageStatus = .sent // Default for messages from Firestore
    
    // For Firestore compatibility
    enum CodingKeys: String, CodingKey {
        case id, athleteId, userId, username, message, timestamp
    }
    
    // Initialize from Firestore data
    init(id: String, athleteId: String, userId: String, username: String, message: String, timestamp: Date) {
        self.id = id
        self.athleteId = athleteId
        self.userId = userId
        self.username = username
        self.message = message
        self.timestamp = timestamp
        self.status = .sent // Messages from Firestore are already sent
    }
    
    // Initialize for optimistic updates (local messages)
    init(athleteId: String, userId: String, username: String, message: String, status: MessageStatus = .sending) {
        self.id = UUID().uuidString + "_local" // Temporary ID
        self.athleteId = athleteId
        self.userId = userId
        self.username = username
        self.message = message
        self.timestamp = Date()
        self.status = status
    }
    
    // Initialize from Firestore document
    init?(documentId: String, data: [String: Any], athleteId: String) {
        guard let userId = data["userId"] as? String,
              let username = data["username"] as? String,
              let message = data["message"] as? String,
              let timestamp = data["timestamp"] as? Date else {
            return nil
        }
        
        self.id = documentId
        self.athleteId = athleteId
        self.userId = userId
        self.username = username
        self.message = message
        self.timestamp = timestamp
        self.status = .sent
    }
}

struct ChatRoom: Identifiable {
    let id: String
    let athleteId: String
    let athleteName: String
    var lastMessage: ChatMessage?
    var participantCount: Int = 0
}