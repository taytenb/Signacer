import SwiftUI
import AVKit

struct AthleteView: View {
    let athlete: Athlete
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Player at the top (plays the athlete’s highlight video)
                if let url = URL(string: athlete.highlightVideoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                        .cornerRadius(10)
                }
                
                HStack {
                    // Athlete picture placeholder
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.neonGreen)
                    Text("@\(athlete.name)")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Sections for Perks, Events, Communities, Giveaways, etc.
                SectionView(title: "Perks",
                            items: athlete.perks.map { $0.title },
                            links: athlete.perks.map { $0.link })
                
                SectionView(title: "Events",
                            items: athlete.events.map { $0.title },
                            links: athlete.events.map { _ in "#" }) // Replace "#" with actual links if available
                
                SectionView(title: "Communities",
                            items: athlete.communities.map { $0.title },
                            links: athlete.communities.map { $0.link })
                
                SectionView(title: "Giveaways",
                            items: athlete.giveaways.map { $0.title },
                            links: athlete.giveaways.map { _ in "#" })
                
                // Link to external content (e.g. YouTube)
                if let contentURL = URL(string: athlete.contentURL) {
                    Link("Watch Content", destination: contentURL)
                        .padding()
                        .background(Color.neonGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                SectionView(title: "Products",
                            items: athlete.products.map { $0.title },
                            links: athlete.products.map { $0.link })
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

struct SectionView: View {
    let title: String
    let items: [String]
    let links: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            ForEach(0..<items.count, id: \.self) { index in
                if let url = URL(string: links[index]) {
                    Link(destination: url) {
                        Text(items[index])
                            .padding(8)
                            .background(Color.neonGreen)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                } else {
                    Text(items[index])
                        .padding(8)
                        .background(Color.neonGreen)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}
