import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var hasMoreMessages = true
    @Published var isLoadingMore = false
    
    private var listener: ListenerRegistration?
    private let athleteId: String
    private let username: String
    private let firestoreManager = FirestoreManager.shared
    private let pageSize = 50
    
    init(athleteId: String, username: String) {
        self.athleteId = athleteId
        self.username = username
        startListening()
    }
    
    deinit {
        stopListening()
    }
    
    private func startListening() {
        isLoading = true
        listener = firestoreManager.listenToMessages(athleteId: athleteId, limit: pageSize) { [weak self] messages in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.updateMessages(with: messages)
                self?.hasMoreMessages = messages.count >= self?.pageSize ?? 50
            }
        }
    }
    
    private func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    private func updateMessages(with firestoreMessages: [ChatMessage]) {
        // Separate local optimistic messages from Firestore messages
        let localMessages = messages.filter { $0.id.hasSuffix("_local") }
        
        // Update Firestore messages
        var updatedMessages = firestoreMessages.map { message in
            var updatedMessage = message
            updatedMessage.isFromCurrentUser = message.userId == Auth.auth().currentUser?.uid
            return updatedMessage
        }
        
        // Add local messages that haven't been confirmed yet
        let confirmedMessageTexts = Set(firestoreMessages.map { $0.message })
        let pendingLocalMessages = localMessages.filter { localMessage in
            !confirmedMessageTexts.contains(localMessage.message) || localMessage.status == .failed
        }
        
        updatedMessages.append(contentsOf: pendingLocalMessages)
        
        // Sort by timestamp
        updatedMessages.sort { $0.timestamp < $1.timestamp }
        
        self.messages = updatedMessages
    }
    
    func sendMessage(_ text: String, completion: @escaping (Bool) -> Void) {
        guard let currentUser = Auth.auth().currentUser,
              let userId = currentUser.uid as String?,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(false)
            return
        }
        
        let messageText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create optimistic local message
        let optimisticMessage = ChatMessage(
            athleteId: athleteId,
            userId: userId,
            username: username,
            message: messageText,
            status: .sending
        )
        
        var updatedOptimisticMessage = optimisticMessage
        updatedOptimisticMessage.isFromCurrentUser = true
        
        // Add optimistic message immediately
        messages.append(updatedOptimisticMessage)
        
        // Send to Firestore
        firestoreManager.sendMessage(
            athleteId: athleteId,
            userId: userId,
            username: username,
            message: messageText
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    // Message will be updated through the listener
                    completion(true)
                } else {
                    // Mark the optimistic message as failed
                    if let index = self?.messages.firstIndex(where: { $0.id == optimisticMessage.id }) {
                        self?.messages[index].status = .failed
                    }
                    self?.error = error
                    completion(false)
                }
            }
        }
    }
    
    func retryFailedMessage(_ message: ChatMessage) {
        guard message.status == .failed,
              let currentUser = Auth.auth().currentUser,
              let userId = currentUser.uid as String? else {
            return
        }
        
        // Update status to sending
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].status = .sending
        }
        
        // Retry sending
        firestoreManager.sendMessage(
            athleteId: athleteId,
            userId: userId,
            username: username,
            message: message.message
        ) { [weak self] success, error in
            DispatchQueue.main.async {
                if let index = self?.messages.firstIndex(where: { $0.id == message.id }) {
                    if success {
                        // Message will be updated through listener, remove local copy
                        self?.messages.remove(at: index)
                    } else {
                        // Mark as failed again
                        self?.messages[index].status = .failed
                        self?.error = error
                    }
                }
            }
        }
    }
    
    func loadMoreMessages() {
        guard !isLoadingMore, hasMoreMessages, !messages.isEmpty else { return }
        
        isLoadingMore = true
        
        // Find the oldest Firestore message (not local)
        let firestoreMessages = messages.filter { !$0.id.hasSuffix("_local") }
        guard let oldestMessage = firestoreMessages.first else {
            isLoadingMore = false
            return
        }
        
        firestoreManager.fetchMoreMessages(athleteId: athleteId, beforeMessage: oldestMessage, limit: pageSize) { [weak self] newMessages in
            DispatchQueue.main.async {
                self?.isLoadingMore = false
                
                if newMessages.isEmpty {
                    self?.hasMoreMessages = false
                } else {
                    // Add older messages to the beginning
                    let updatedMessages = newMessages.map { message in
                        var updatedMessage = message
                        updatedMessage.isFromCurrentUser = message.userId == Auth.auth().currentUser?.uid
                        return updatedMessage
                    }
                    
                    self?.messages.insert(contentsOf: updatedMessages, at: 0)
                    self?.hasMoreMessages = newMessages.count >= self?.pageSize ?? 50
                }
            }
        }
    }
} 