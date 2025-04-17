import SwiftUI
import Firebase
import FirebaseStorage
import UIKit

struct DatabaseSeeder {
    // Add this property to keep track of pending operations
    private static var pendingOperations = 0
    private static var completionHandler: (() -> Void)? = nil
    
    static func seedDatabase(completion: @escaping () -> Void = {}) {
        completionHandler = completion
        pendingOperations = 1 // Start with 1 for the initial operation
        
        // Collect all image names that need to be uploaded
        let athleteImages = ["AthleteJJ", "SeanOMalley", "JJGIF", "SeanGIF", "JustinJefferson", "SeanOMalley"]
        let perkImages = ["Amazon", "Gatorade", "Underarmour", "Oakley", "PrizePicks", "RYSE", "YoungLA", "Sanabul", "HappyDad", "WBrand"]
        let eventImages = ["PopupEventJJ", "JJ7on7", "zoom", "PopupEventSM", "SM7on7"]
        let communityImages = ["Discord", "Charity"]
        let giveawayImages = ["auto", "tickets", "cleats white", "UFCTickets", "SugaWeekend", "ColdPlunge"]
        
        let allImages = athleteImages + perkImages + eventImages + communityImages + giveawayImages
        
        // Upload all images
        uploadAssetImages(imageNames: allImages, path: "app_assets") { imageURLMap in
            // Now seed the database with the image URLs
            let db = Firestore.firestore()
            seedAthletes(db: db, imageURLMap: imageURLMap)
            
            // Complete the operation
            operationCompleted()
        }
    }
    
    private static func operationCompleted() {
        pendingOperations -= 1
        if pendingOperations == 0 {
            DispatchQueue.main.async {
                completionHandler?()
            }
        }
    }
    
    private static func seedAthletes(db: Firestore, imageURLMap: [String: String]) {
        // Add debug print to see what's happening
        print("Starting to seed athletes with imageURLMap: \(imageURLMap)")
        
        // Increment pending operations for both athletes
        pendingOperations += 2
        
        // Justin Jefferson
        let jeffersonRef = db.collection("athletes").document("athlete1")
        jeffersonRef.setData([
            "id": "athlete1",
            "name": "Justin Jefferson",
            "profilePicURL": imageURLMap["AthleteJJ"] ?? "AthleteJJ",
            "highlightVideoURL": imageURLMap["JJGIF"] ?? "JJGIF",
            "contentURL": "https://youtube.com"
        ]) { error in
            if let error = error {
                print("Error seeding Justin Jefferson: \(error.localizedDescription)")
                operationCompleted()
            } else {
                print("Successfully seeded Justin Jefferson")
                // Add perks subcollection with updated image URLs
                let perks = [
                    ["id": "perk1", "title": "15% off Amazon", "link": "https://amazon.com", "imageURL": imageURLMap["Amazon"] ?? "Amazon"],
                    ["id": "perk2", "title": "10% off Gatorade", "link": "https://gatorade.com", "imageURL": imageURLMap["Gatorade"] ?? "Gatorade"],
                    ["id": "perk3", "title": "5% off Under Armor", "link": "https://underarmour.com", "imageURL": imageURLMap["Underarmour"] ?? "Underarmour"],
                    ["id": "perk4", "title": "Oakley Discount", "link": "https://www.oakley.com", "imageURL": imageURLMap["Oakley"] ?? "Oakley"]
                ]
                
                addSubcollectionData(ref: jeffersonRef, collectionName: "perks", data: perks)
                
                // Add events subcollection
                let events = [
                    [
                        "id": "event1",
                        "title": "Justin Jefferson Pop-Up Event",
                        "description": "Meet Justin at a special brand pop-up event",
                        "date": Timestamp(date: Date().addingTimeInterval(14*24*60*60)),
                        "location": "Minneapolis, MN",
                        "maxGuests": 100,
                        "imageURL": imageURLMap["PopupEventJJ"] ?? "PopupEventJJ"
                    ],
                    [
                        "id": "event2",
                        "title": "7-on-7 Tournament by Jettas",
                        "description": "Join Justin's tournament for young athletes",
                        "date": Timestamp(date: Date().addingTimeInterval(30*24*60*60)),
                        "location": "US Bank Stadium",
                        "maxGuests": 200,
                        "imageURL": imageURLMap["JJ7on7"] ?? "JJ7on7"
                    ],
                    [
                        "id": "event3",
                        "title": "Zoom Q&A Session",
                        "description": "Virtual Q&A with Justin Jefferson",
                        "date": Timestamp(date: Date().addingTimeInterval(7*24*60*60)),
                        "location": "Online",
                        "maxGuests": 500,
                        "imageURL": imageURLMap["zoom"] ?? "zoom"
                    ]
                ]
                
                addSubcollectionData(ref: jeffersonRef, collectionName: "events", data: events)
                
                // Add communities subcollection
                let communities = [
                    ["id": "comm1", "title": "Discord Community", "link": "https://discord.com", "imageURL": imageURLMap["Discord"] ?? "Discord"],
                    ["id": "comm2", "title": "Social Impact Initiative", "link": "https://charity.org", "imageURL": imageURLMap["Charity"] ?? "Charity"]
                ]
                
                addSubcollectionData(ref: jeffersonRef, collectionName: "communities", data: communities)
                
                // Add giveaways subcollection
                let giveaways = [
                    [
                        "id": "give1",
                        "title": "Signed Game Item",
                        "description": "Win a signed item from every game ($5 entry)",
                        "imageURL": imageURLMap["auto"] ?? "auto",
                        "endDate": Timestamp(date: Date().addingTimeInterval(90*24*60*60))
                    ],
                    [
                        "id": "give2",
                        "title": "Game Ticket Giveaway",
                        "description": "Win tickets to an upcoming Vikings game",
                        "imageURL": imageURLMap["tickets"] ?? "tickets",
                        "endDate": Timestamp(date: Date().addingTimeInterval(45*24*60*60))
                    ],
                    [
                        "id": "give3",
                        "title": "Brand Gift Bag",
                        "description": "Win Under Armour shoes, Oakley glasses, and more",
                        "imageURL": imageURLMap["cleats white"] ?? "cleats white",
                        "endDate": Timestamp(date: Date().addingTimeInterval(60*24*60*60))
                    ]
                ]
                
                addSubcollectionData(ref: jeffersonRef, collectionName: "giveaways", data: giveaways)
                
                // Add polls subcollection
                let polls = [
                    [
                        "id": "poll1",
                        "question": "What cleats should I wear?",
                        "options": ["Purple", "White", "Yellow"],
                        "endDate": Timestamp(date: Date().addingTimeInterval(3*24*60*60))
                    ]
                ]
                
                addSubcollectionData(ref: jeffersonRef, collectionName: "polls", data: polls)
                
                operationCompleted()
            }
        }
        
        // Sean O'Malley (Similar structure to Justin Jefferson)
        let omalleyRef = db.collection("athletes").document("athlete2")
        omalleyRef.setData([
            "id": "athlete2",
            "name": "Sean O'Malley",
            "profilePicURL": imageURLMap["SeanOMalley"] ?? "SeanOMalley",
            "highlightVideoURL": imageURLMap["SeanGIF"] ?? "SeanGIF",
            "contentURL": "https://youtube.com"
        ]) { error in
            if let error = error {
                print("Error seeding Sean O'Malley: \(error.localizedDescription)")
                operationCompleted()
            } else {
                print("Successfully seeded Sean O'Malley")
                // Add perks for Sean O'Malley
                let seanPerks = [
                    [
                        "id": "perk1", 
                        "title": "PrizePicks – Free $20 for New Sign-Up", 
                        "link": "https://prizepicks.com", 
                        "imageURL": imageURLMap["PrizePicks"] ?? "PrizePicks"
                    ],
                    [
                        "id": "perk2", 
                        "title": "RYSE – First Protein Powder Free & 20% off bundles", 
                        "link": "https://rysesupps.com", 
                        "imageURL": imageURLMap["RYSE"] ?? "RYSE"
                    ],
                    [
                        "id": "perk3", 
                        "title": "YoungLA – Buy 1, Get 1 Free on shirts", 
                        "link": "https://youngla.com", 
                        "imageURL": imageURLMap["YoungLA"] ?? "YoungLA"
                    ],
                    [
                        "id": "perk4", 
                        "title": "Sanabul – 25% off", 
                        "link": "https://sanabul.com", 
                        "imageURL": imageURLMap["Sanabul"] ?? "Sanabul"
                    ],
                    [
                        "id": "perk5", 
                        "title": "Happy Dad – 15% off & Free Hat", 
                        "link": "https://happydad.com", 
                        "imageURL": imageURLMap["HappyDad"] ?? "HappyDad"
                    ],
                    [
                        "id": "perk6", 
                        "title": "W – Free First Bundle & 10% off", 
                        "link": "https://w.com", 
                        "imageURL": imageURLMap["WBrand"] ?? "WBrand"
                    ]
                ]
                
                addSubcollectionData(ref: omalleyRef, collectionName: "perks", data: seanPerks)
                
                // Add events subcollection
                let events = [
                    [
                        "id": "event1",
                        "title": "Sean O'Malley Pop-Up Event",
                        "description": "Meet Sean at a special brand pop-up event",
                        "date": Timestamp(date: Date().addingTimeInterval(14*24*60*60)),
                        "location": "Minneapolis, MN",
                        "maxGuests": 100,
                        "imageURL": imageURLMap["PopupEventSM"] ?? "PopupEventSM"
                    ],
                    [
                        "id": "event2",
                        "title": "7-on-7 Tournament by Jettas",
                        "description": "Join Sean's tournament for young athletes",
                        "date": Timestamp(date: Date().addingTimeInterval(30*24*60*60)),
                        "location": "US Bank Stadium",
                        "maxGuests": 200,
                        "imageURL": imageURLMap["SM7on7"] ?? "SM7on7"
                    ],
                    [
                        "id": "event3",
                        "title": "Zoom Q&A Session",
                        "description": "Virtual Q&A with Sean O'Malley",
                        "date": Timestamp(date: Date().addingTimeInterval(7*24*60*60)),
                        "location": "Online",
                        "maxGuests": 500,
                        "imageURL": imageURLMap["zoom"] ?? "zoom"
                    ]
                ]
                
                addSubcollectionData(ref: omalleyRef, collectionName: "events", data: events)
                
                // Add communities subcollection
                let communities = [
                    ["id": "comm1", "title": "Discord Community", "link": "https://discord.com", "imageURL": imageURLMap["Discord"] ?? "Discord"],
                    ["id": "comm2", "title": "Social Impact Initiative", "link": "https://charity.org", "imageURL": imageURLMap["Charity"] ?? "Charity"]
                ]
                
                addSubcollectionData(ref: omalleyRef, collectionName: "communities", data: communities)
                
                // Add giveaways subcollection
                let giveaways = [
                    [
                        "id": "give1",
                        "title": "Signed Game Item",
                        "description": "Win a signed item from every game ($5 entry)",
                        "imageURL": imageURLMap["auto"] ?? "auto",
                        "endDate": Timestamp(date: Date().addingTimeInterval(90*24*60*60))
                    ],
                    [
                        "id": "give2",
                        "title": "Game Ticket Giveaway",
                        "description": "Win tickets to an upcoming Vikings game",
                        "imageURL": imageURLMap["tickets"] ?? "tickets",
                        "endDate": Timestamp(date: Date().addingTimeInterval(45*24*60*60))
                    ],
                    [
                        "id": "give3",
                        "title": "Brand Gift Bag",
                        "description": "Win Under Armour shoes, Oakley glasses, and more",
                        "imageURL": imageURLMap["cleats white"] ?? "cleats white",
                        "endDate": Timestamp(date: Date().addingTimeInterval(60*24*60*60))
                    ]
                ]
                
                addSubcollectionData(ref: omalleyRef, collectionName: "giveaways", data: giveaways)
                
                // Add polls subcollection
                let polls = [
                    [
                        "id": "poll1",
                        "question": "What cleats should I wear?",
                        "options": ["Purple", "White", "Yellow"],
                        "endDate": Timestamp(date: Date().addingTimeInterval(3*24*60*60))
                    ]
                ]
                
                addSubcollectionData(ref: omalleyRef, collectionName: "polls", data: polls)
                
                operationCompleted()
            }
        }
        
        // Update card documents
        let jeffersonCard = db.collection("cards").document("card1")
        jeffersonCard.setData([
            "athleteId": "athlete1",
            "backgroundImage": imageURLMap["JustinJefferson"] ?? "JustinJefferson",
            "rarity": "1/100"
        ])
        
        let omalleyCard = db.collection("cards").document("card2")
        omalleyCard.setData([
            "athleteId": "athlete2",
            "backgroundImage": imageURLMap["SeanOMalley"] ?? "SeanOMalley",
            "rarity": "1/50"
        ])
    }
    
    private static func addSubcollectionData(ref: DocumentReference, collectionName: String, data: [[String: Any]]) {
        let collection = ref.collection(collectionName)
        
        for item in data {
            if let id = item["id"] as? String {
                collection.document(id).setData(item) { error in
                    if let error = error {
                        print("Error adding \(collectionName) item: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Upload image from asset catalog to Firebase Storage
    private static func uploadAssetImage(named imageName: String, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = UIImage(named: imageName) else {
            print("⚠️ Image \(imageName) not found in asset catalog")
            completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image \(imageName) not found in asset catalog"])))
            return
        }
        
        // Compress the image
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        // Create a storage reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("\(path)/\(imageName).jpg")
        
        // Upload the image
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("⚠️ Failed to get download URL for \(imageName): \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let downloadURL = url {
                    print("✅ Got download URL for \(imageName): \(downloadURL.absoluteString)")
                    completion(.success(downloadURL.absoluteString))
                } else {
                    print("⚠️ No download URL for \(imageName)")
                    completion(.failure(NSError(domain: "app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                }
            }
        }
    }
    
    // Add image batch upload function
    private static func uploadAssetImages(imageNames: [String], path: String, completion: @escaping ([String: String]) -> Void) {
        var imageURLs: [String: String] = [:]
        let group = DispatchGroup()
        
        for imageName in imageNames {
            group.enter()
            uploadAssetImage(named: imageName, path: path) { result in
                switch result {
                case .success(let url):
                    imageURLs[imageName] = url
                case .failure(let error):
                    print("Error uploading \(imageName): \(error.localizedDescription)")
                    // Use the original name as fallback
                    imageURLs[imageName] = imageName
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(imageURLs)
        }
    }
}