import SwiftUI
import Firebase
import UIKit

@main
struct signacerApp: App {
    // Use UIApplicationDelegateAdaptor to connect your AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark) // Use dark mode to align with the black theme
        }
    }
}
