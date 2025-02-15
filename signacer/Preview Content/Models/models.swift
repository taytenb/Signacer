import Foundation

struct User {
    let uid: String
    let email: String
    let username: String
    let profilePicURL: String
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
    let products: [Product]
}

struct Perk: Identifiable {
    let id: String
    let title: String
    let link: String
}

struct Event: Identifiable {
    let id: String
    let title: String
    let description: String
    let date: Date
}

struct Community: Identifiable {
    let id: String
    let title: String
    let link: String
}

struct Giveaway: Identifiable {
    let id: String
    let title: String
    let description: String
}

struct Product: Identifiable {
    let id: String
    let title: String
    let description: String
    let link: String
}
