import SwiftUI

struct AdminView: View {
    @State private var isSeeding = false
    @State private var seedingComplete = false
    
    var body: some View {
        VStack {
            Button("Seed Database") {
                isSeeding = true
                DatabaseSeeder.seedDatabase {
                    // This will be called when seeding is complete
                    isSeeding = false
                    seedingComplete = true
                }
            }
            .disabled(isSeeding)
            .padding()
            
            if isSeeding {
                ProgressView("Seeding database...")
                    .padding()
            }
            
            if seedingComplete {
                Text("Database seeded successfully!")
                    .foregroundColor(.green)
                    .padding()
            }
        }
    }
}