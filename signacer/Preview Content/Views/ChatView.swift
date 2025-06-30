import SwiftUI

struct ChatView: View {
    let athleteId: String
    let athleteName: String
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText = ""
    @Environment(\.presentationMode) var presentationMode
    
    // Custom initializer that takes username
    init(athleteId: String, athleteName: String, username: String) {
        self.athleteId = athleteId
        self.athleteName = athleteName
        self._viewModel = StateObject(wrappedValue: ChatViewModel(athleteId: athleteId, username: username))
    }
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("\(athleteName) Community Chat")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding()
            
            // Messages
            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView("Loading messages...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            // Load more button at top - styled to match your theme
                            if viewModel.hasMoreMessages {
                                HStack {
                                    Spacer()
                                    if viewModel.isLoadingMore {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .neonGreen))
                                            .scaleEffect(0.8)
                                    } else {
                                        Button("Load older messages") {
                                            viewModel.loadMoreMessages()
                                        }
                                        .foregroundColor(.neonGreen)
                                        .font(.caption)
                                        .padding(.vertical, 8)
                                    }
                                    Spacer()
                                }
                            }
                            
                            // Messages
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message) {
                                    // Retry failed messages
                                    if message.status == .failed {
                                        viewModel.retryFailedMessage(message)
                                    }
                                }
                                .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        // Auto-scroll to bottom when new messages arrive
                        if let lastMessage = viewModel.messages.last,
                           Date().timeIntervalSince(lastMessage.timestamp) < 2 {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        // Scroll to bottom when chat first opens
                        if let lastMessage = viewModel.messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Error display - styled to match your theme
            if let error = viewModel.error {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }
            
            // Input field
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .background(Color.black)
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let text = messageText
        messageText = "" // Clear immediately for better UX
        
        viewModel.sendMessage(text) { success in
            // Optimistic updates handle the UI, no need to restore text
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    let onRetry: () -> Void
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer() // Push current user messages to the right
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                // Name and time together, smaller text
                HStack(spacing: 4) {
                    if message.isFromCurrentUser {
                        // Status indicator for current user
                        switch message.status {
                        case .sending:
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        case .sent:
                            Image(systemName: "checkmark")
                                .foregroundColor(.gray)
                                .font(.caption2)
                        case .failed:
                            Button(action: onRetry) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption2)
                            }
                        }
                    }
                    if message.isFromCurrentUser{
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        
                        Text(message.username)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    else{
                        Text(message.username)
                            .font(.caption)
                            .foregroundColor(.neonGreen)
                        
                        Text(message.timestamp, style: .time)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                
                // Message bubble
                Text(message.message)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Group {
                            if message.status == .failed {
                                Color.red.opacity(0.3)
                            } else if message.isFromCurrentUser {
                                Color.blue.opacity(0.3)
                            } else {
                                Color.gray.opacity(0.3)
                            }
                        }
                    )
                    .cornerRadius(10)
                    .opacity(message.status == .sending ? 0.7 : 1.0)
            }
            
            if !message.isFromCurrentUser {
                Spacer() // Push other users' messages to the left
            }
        }
        .padding(.vertical, 4)
    }
} 
