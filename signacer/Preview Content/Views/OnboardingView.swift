import SwiftUI

struct OnboardingView: View {
    @State private var dateOfBirth: Date = Date()
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var isOnboardingComplete = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Complete Your Profile")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(.neonGreen)
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(CustomTextFieldStyle())
            
            TextField("Username", text: $username)
                .textFieldStyle(CustomTextFieldStyle())
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                isOnboardingComplete = true
            }) {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $isOnboardingComplete) {
            HomeView()
        }
    }
} 