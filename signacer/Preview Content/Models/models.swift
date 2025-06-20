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
            bio: ""
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
