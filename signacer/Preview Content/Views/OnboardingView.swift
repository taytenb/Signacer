import SwiftUI

struct OnboardingView: View {
    @State private var age: Int = 18
    @State private var phoneNumber: String = ""
    @State private var username: String = ""
    @State private var isOnboardingComplete = false
    
    // Age range for picker
    let ageRange = 13...100
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Complete Your Profile")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            // Simple age picker
            HStack {
                Text("Age")
                    .foregroundColor(.white)
                    .frame(width: 80, alignment: .leading)
                
                Picker("Select your age", selection: $age) {
                    ForEach(ageRange, id: \.self) { age in
                        Text("\(age)")
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .clipped()
                .accentColor(.neonGreen)
            }
            .padding(.horizontal)
            
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(CustomTextFieldStyle())
                .keyboardType(.phonePad)
            
            TextField("Username", text: $username)
                .textFieldStyle(CustomTextFieldStyle())
                .autocapitalization(.none)
            
            Button(action: {
                // Save user data
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                UserDefaults.standard.set(age, forKey: "userAge")
                UserDefaults.standard.set(phoneNumber, forKey: "userPhone")
                UserDefaults.standard.set(username, forKey: "username")
                isOnboardingComplete = true
            }) {
                Text("Continue")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.neonGreen)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            .disabled(username.isEmpty || phoneNumber.isEmpty)
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .fullScreenCover(isPresented: $isOnboardingComplete) {
            HomeView()
        }
    }
} 