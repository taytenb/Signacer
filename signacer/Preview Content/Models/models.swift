import Foundation

struct User {
    let uid: String
    let email: String
    let username: String
    let profilePicURL: String
    let age: Int
    let phoneNumber: String
    let bio: String = "Book lover, sports fanatic, and lifelong fan of The Weeknd. Whether I'm diving into a great novel, catching the latest game, or vibing to XO classics, I'm all about passion and community."
}

struct Athlete: Identifiable {
    let id: String
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
