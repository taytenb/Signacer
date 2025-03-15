import SwiftUI

struct ChatView: View {
    let athleteName: String
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(id: "1", sender: "Mike", message: "Love your game!", timestamp: Date().addingTimeInterval(-3600)),
        ChatMessage(id: "2", sender: "Sarah", message: "Can't wait for the next event!", timestamp: Date().addingTimeInterval(-1800)),
        ChatMessage(id: "3", sender: "John", message: "That last play was amazing!", timestamp: Date().addingTimeInterval(-900))
    ]
    @Environment(\.presentationMode) var presentationMode
    
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
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(.horizontal)
            }
            
            // Input field
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .foregroundColor(.white)
                
                Button(action: {
                    if !messageText.isEmpty {
                        let newMessage = ChatMessage(
                            id: UUID().uuidString,
                            sender: "You",
                            message: messageText,
                            timestamp: Date()
                        )
                        messages.append(newMessage)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.neonGreen)
                }
            }
            .padding()
        }
        .background(Color.black)
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(message.sender)
                    .font(.headline)
                    .foregroundColor(.neonGreen)
                
                Spacer()
                
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(message.message)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
        }
        .padding(.vertical, 4)
    }
}

struct ChatMessage: Identifiable {
    let id: String
    let sender: String
    let message: String
    let timestamp: Date
} 