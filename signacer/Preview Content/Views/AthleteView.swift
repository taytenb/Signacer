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
        
        if let gifPath = Bundle.main.path(forResource: name, ofType: "gif") {
            let url = URL(fileURLWithPath: gifPath)
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            print("Could not find GIF: \(name).gif")
            // Maybe load a placeholder image
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
    @State private var showChat = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Video Player at the top (plays the athlete's highlight video)
                    if athlete.highlightVideoURL.starts(with: "http") {
                        if let url = URL(string: athlete.highlightVideoURL) {
                            VideoPlayer(player: AVPlayer(url: url))
                                .frame(height: 200)
                        }
                    } else if !athlete.highlightVideoURL.isEmpty {
                        GIFPlayer(name: athlete.highlightVideoURL)
                            .frame(height: 200)
                    }
                    
                    // Reduced padding here - from 60 to 20
                    Spacer().frame(height: 20)
                    
                    VStack {
                        // Fixed AsyncImage handling with remote/local support
                        if athlete.profilePicURL.starts(with: "http") {
                            // Remote image
                            AsyncImage(url: URL(string: athlete.profilePicURL)) { phase in
                                if phase.error != nil {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.gray)
                                } else if let image = phase.image {
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    ProgressView()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200, alignment: .top)
                            .clipped()
                            .foregroundColor(.neonGreen)
                        } else {
                            // Local image
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
                        }
                        Text("@\(athlete.username)")
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
                    
                    if !athlete.polls.isEmpty {
                        ExpandableSectionView(
                            title: "Polls",
                            isExpanded: expandedSection == "Polls",
                            onTap: { expandedSection = expandedSection == "Polls" ? nil : "Polls" }
                        ) {
                            PollsView(polls: athlete.polls)
                        }
                    }
                    
                }
            }
            
            // Chat button as a separate overlay
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showChat = true
                    }) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.neonGreen)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.7)))
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView(athleteName: athlete.name)
        }
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
            // Using the reusable image component
            RemoteOrLocalImageView(
                urlString: event.imageURL,
                height: 150,
                fallbackSystemName: "calendar"
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

// Also let's create a simplified component for the small icon images in SectionView
struct IconImageView: View {
    let urlString: String
    
    var body: some View {
        if urlString.starts(with: "http") {
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 30, height: 30)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                case .failure:
                    fallbackIconView
                @unknown default:
                    fallbackIconView
                }
                
            }
        } else {
            if let _ = UIImage(named: urlString) {
                Image(urlString)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
            } else {
                fallbackIconView
            }
        }
    }
    
    private var fallbackIconView: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .padding(6)
            .background(Color.white)
            .cornerRadius(8)
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
                sectionItemView(index: index)
            }
        }
        .padding(.horizontal)
    }
    
    // Breaking down complex expressions into smaller, more manageable views
    private func sectionItemView(index: Int) -> some View {
        let hasValidURL = URL(string: links[index]) != nil
        
        return Group {
            if hasValidURL {
                Link(destination: URL(string: links[index])!) {
                    itemContentView(index: index)
                }
            } else {
                itemContentView(index: index)
            }
        }
    }
    
    private func itemContentView(index: Int) -> some View {
        HStack {
            // Using simplified icon component
            IconImageView(urlString: images[index])
            
            Text(items[index])
                .foregroundColor(.white)
                .padding(.leading, 8)
            
            Spacer()
            
            if URL(string: links[index]) != nil {
                Image(systemName: "arrow.right")
                    .foregroundColor(.neonGreen)
            }
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

struct PollsView: View {
    let polls: [Poll]
    @State private var selectedOptions: [String: String] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(polls) { poll in
                VStack(alignment: .leading, spacing: 12) {
                    Text(poll.question)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ForEach(poll.options, id: \.self) { option in
                        Button(action: { 
                            selectedOptions[poll.id] = option
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(.black)
                                Spacer()
                                if selectedOptions[poll.id] == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.black)
                                }
                            }
                            .padding()
                            .background(selectedOptions[poll.id] == option ? Color.neonGreen : Color.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    Text("Poll ends \(poll.endDate, style: .date)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
}

// Reusable image view component to standardize image handling
struct RemoteOrLocalImageView: View {
    let urlString: String
    let height: CGFloat
    let fallbackSystemName: String
    
    var body: some View {
        if urlString.starts(with: "http") {
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: height)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: height)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(8)
                case .failure:
                    fallbackView
                @unknown default:
                    fallbackView
                }
            }
        } else {
            if let _ = UIImage(named: urlString) {
                Image(urlString)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(8)
            } else {
                fallbackView
            }
        }
    }
    
    private var fallbackView: some View {
        ZStack {
            Color.gray
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .cornerRadius(8)
            
            Image(systemName: fallbackSystemName)
                .resizable()
                .scaledToFit()
                .frame(width: height * 0.3, height: height * 0.3)
                .foregroundColor(.white)
        }
    }
}

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
            // Using the reusable image component
            RemoteOrLocalImageView(
                urlString: giveaway.imageURL,
                height: 150,
                fallbackSystemName: "gift.fill"
            )
            .allowsHitTesting(false)
            
            // Text content section
            VStack(alignment: .leading, spacing: 4) {
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
        }
        .padding()
        .background(Color.black.opacity(0.5))
        .cornerRadius(12)
    }
}
