import SwiftUI

struct RSVPView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var numberOfGuests = 1
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.description)
                        .font(.subheadline)
                    if let date = event.date {
                        Text(date, style: .date)
                    }
                }
                
                Section(header: Text("Your Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Stepper("Number of Guests: \(numberOfGuests)", value: $numberOfGuests, in: 1...4)
                }
                
                Button(action: submitRSVP) {
                    Text("Confirm RSVP")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.neonGreen)
                .disabled(name.isEmpty || email.isEmpty)
            }
            .navigationTitle("RSVP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("RSVP Confirmed", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for RSVPing to \(event.title). We'll send the details to \(email).")
            }
        }
    }
    
    private func submitRSVP() {
        // Here you would typically send the RSVP data to your backend
        showingConfirmation = true
    }
} 