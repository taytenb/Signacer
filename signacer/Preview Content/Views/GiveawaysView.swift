import SwiftUI

struct GiveawaysView: View {
    let giveaways: [Giveaway]
    @State private var showingConfirmation = false
    @State private var selectedGiveaway: Giveaway?
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(giveaways) { giveaway in
                GiveawayCard(giveaway: giveaway) {
                    selectedGiveaway = giveaway
                    showingConfirmation = true
                }
            }
        }
        .padding(.horizontal)
        .alert("Enter Giveaway", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Enter") {
                enterGiveaway()
            }
        } message: {
            if let giveaway = selectedGiveaway {
                Text("Would you like to enter the giveaway for \(giveaway.title)?")
            }
        }
    }
    
    private func enterGiveaway() {
        // Here you would typically handle the giveaway entry in your backend
    }
}

struct GiveawayCard: View {
    let giveaway: Giveaway
    let onEnterTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // First try to load from asset catalog
            Image(giveaway.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    Group {
                        if UIImage(named: giveaway.imageURL) == nil {
                            // Fallback to URL if not in assets
                            if let url = URL(string: giveaway.imageURL) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "gift.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }
                            } else {
                                // Show fallback icon if neither asset nor valid URL
                                Image(systemName: "gift.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                )
            
            Text(giveaway.title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(giveaway.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("Ends \(giveaway.endDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: onEnterTap) {
                    Text(giveaway.isEntered ? "Entered" : "Enter Now")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(giveaway.isEntered ? Color.gray : Color.neonGreen)
                        .foregroundColor(giveaway.isEntered ? .white : .black)
                        .cornerRadius(8)
                }
                .disabled(giveaway.isEntered)
            }
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }
} 