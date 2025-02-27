import SwiftUI
import AVKit
import WebKit

struct GIFPlayer: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        
        if let gifPath = Bundle.main.path(forResource: "JJGIF", ofType: "gif") {
            let url = URL(fileURLWithPath: gifPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // No update needed
    }
}

struct AthleteView: View {
    let athlete: Athlete
    @State private var expandedSection: String?
    @State private var selectedPoll: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Video Player at the top (plays the athlete's highlight video)
                if athlete.highlightVideoURL == "JJGIF.gif" {
                    GIFPlayer(name: "JJGIF")
                        .frame(height: 200)
                } else if let url = URL(string: athlete.highlightVideoURL) {
                    VideoPlayer(player: AVPlayer(url: url))
                        .frame(height: 200)
                }
                
                VStack {
                    // Updated Image handling with error state
                    Image(athlete.profilePicURL)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200, alignment: .top)
                        .clipped()
                        .foregroundColor(.neonGreen)
                        .overlay(
                            Group {
                                if UIImage(named: athlete.profilePicURL) == nil {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                    Text("@\(athlete.name)")
                        .font(.title)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                // Only show sections that have content
                if !athlete.perks.isEmpty {
                    ExpandableSectionView(
                        title: "Perks",
                        isExpanded: expandedSection == "Perks",
                        onTap: { expandedSection = expandedSection == "Perks" ? nil : "Perks" }
                    ) {
                        SectionView(title: "",
                                  items: athlete.perks.map { $0.title },
                                  links: athlete.perks.map { $0.link },
                                  images: athlete.perks.map { $0.imageURL })
                    }
                }
                
                if !athlete.events.isEmpty {
                    ExpandableSectionView(
                        title: "Events",
                        isExpanded: expandedSection == "Events",
                        onTap: { expandedSection = expandedSection == "Events" ? nil : "Events" }
                    ) {
                        EventsView(events: athlete.events)
                    }
                }
                
                if !athlete.communities.isEmpty {
                    ExpandableSectionView(
                        title: "Communities",
                        isExpanded: expandedSection == "Communities",
                        onTap: { expandedSection = expandedSection == "Communities" ? nil : "Communities" }
                    ) {
                        SectionView(title: "",
                                  items: athlete.communities.map { $0.title },
                                  links: athlete.communities.map { $0.link },
                                  images: athlete.communities.map { $0.imageURL })
                    }
                }
                
                if !athlete.giveaways.isEmpty {
                    ExpandableSectionView(
                        title: "Giveaways",
                        isExpanded: expandedSection == "Giveaways",
                        onTap: { expandedSection = expandedSection == "Giveaways" ? nil : "Giveaways" }
                    ) {
                        GiveawaysView(giveaways: athlete.giveaways)
                    }
                }
                
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ExpandableSectionView<Content: View>: View {
    let title: String
    let isExpanded: Bool
    let onTap: () -> Void
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.3)) {
                    onTap()
                }
            }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.neonGreen)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
                }
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            if isExpanded {
                VStack {
                    content()
                        .padding(.top, 8)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: isExpanded ? .none : 0)
                .clipped()
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
            }
        }
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal, 4)
    }
}

struct EventsView: View {
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(events) { event in
                EventCard(event: event)
            }
        }
        .padding(.horizontal)
    }
}

struct EventCard: View {
    let event: Event
    @State private var showingRSVP = false
    
    var body: some View {
        VStack(alignment: .leading) {
            // Event Image
            Image(event.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .overlay(
                    Group {
                        if UIImage(named: event.imageURL) == nil {
                            Image(systemName: "calendar")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let date = event.date {
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(event.location)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Button(action: {
                    showingRSVP = true
                }) {
                    Text("RSVP")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.neonGreen)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color.black)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .sheet(isPresented: $showingRSVP) {
            RSVPView(event: event)
        }
    }
}

struct PollView: View {
    let question: String
    let options: [String]
    @Binding var selectedOption: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(options, id: \.self) { option in
                Button(action: { selectedOption = option }) {
                    HStack {
                        Text(option)
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SectionView: View {
    let title: String
    let items: [String]
    let links: [String]
    let images: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
            }
            
            ForEach(0..<items.count, id: \.self) { index in
                if let url = URL(string: links[index]) {
                    Link(destination: url) {
                        HStack {
                            // Logo with background
                            Image(images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(8)
                            
                            Text(items[index])
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.neonGreen)
                        }
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                } else {
                    HStack {
                        // Logo with background
                        Image(images[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding(6)
                            .background(Color.white)
                            .cornerRadius(8)
                        
                        Text(items[index])
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                    }
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
