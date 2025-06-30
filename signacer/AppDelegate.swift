import SwiftUI
import Firebase
import FirebaseFirestore
import UIKit
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Configure Firestore settings BEFORE FirebaseApp.configure()
        let settings = FirestoreSettings()
        
        // Enable offline persistence
        settings.isPersistenceEnabled = true
        
        // Set cache size (default is 40MB, increase if needed)
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited // Unlimited cache
        
        FirebaseApp.configure()
        
        // Apply the settings to Firestore
        let db = Firestore.firestore()
        db.settings = settings
        
        print("✅ Firestore offline persistence enabled")
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL, 
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
