# Signacer

A SwiftUI-based iOS application that connects athletes with their fans through interactive features, events, and real-time chat.

## Overview

Signacer is a fan engagement platform designed to bring athletes and their communities closer together. The app provides a seamless experience for fans to interact with their favorite athletes through exclusive content, events, giveaways, and live chat.

## Features

### User Authentication
- Email/Password authentication via Firebase Auth
- Google Sign-In integration
- Secure user session management
- Profile creation and onboarding flow

### Athlete Profiles
- Browse athlete profiles with highlight videos
- View athlete bio and exclusive content
- Access athlete-specific perks and benefits
- Follow athlete communities

### Events & RSVP
- Discover upcoming athlete events
- RSVP to events with guest management
- View event details (date, location, description)
- Track event participation history
- Event status tracking (confirmed, cancelled, attended)

### Giveaways
- Enter exclusive athlete giveaways
- Track giveaway entries and status
- View giveaway end dates and descriptions
- Manage giveaway participation

### Live Chat
- Real-time chat with athlete communities
- Message status indicators (sending, sent, failed)
- Optimistic UI updates for smooth messaging
- Chat room participant tracking

### Interactive Polls
- Vote on athlete-created polls
- View real-time poll results
- Track voting history

### User Profile
- Customizable profile with photo upload
- Edit personal information (name, age, bio, phone)
- View participation history (events, giveaways, polls)
- Privacy policy access
- Settings management

### UI/UX Features
- Dark mode design with custom color scheme
- Inter font family integration
- Image caching for optimized performance
- Smooth animations and transitions
- QR code support for profile sharing
- Custom splash screen

## Tech Stack

### Frameworks & Libraries
- **SwiftUI**: Modern declarative UI framework
- **Firebase**: Backend services
  - Firebase Authentication
  - Cloud Firestore (database)
  - Firebase Storage (image uploads)
- **UIKit**: Integration for specific UI components

### Architecture
- **MVVM Pattern**: Clean separation of concerns
  - ViewModels: `AuthViewModel`, `ChatViewModel`
  - Models: User, Athlete, Event, Giveaway, Poll, ChatMessage
  - Views: Modular SwiftUI views

### Services
- **FirestoreManager**: Database operations and data management
- **CacheManager**: General caching functionality
- **ImageCacheManager**: Optimized image loading and caching
- **MonitoringService**: Analytics and user action tracking
- **RateLimiter**: API rate limiting and throttling
- **InputValidator**: Form validation and input sanitization
- **AdminManager**: Administrative features and controls
- **ProfileUpdateManager**: Profile update coordination

## Project Structure

```
signacer/
├── signacerApp.swift              # App entry point
├── AppDelegate.swift              # Firebase configuration
├── Info.plist                     # App configuration
├── AdminConfig.plist              # Admin settings
├── Preview Content/
│   ├── Models/
│   │   └── models.swift           # Data models
│   ├── ViewModels/
│   │   ├── AuthviewModel.swift   # Authentication logic
│   │   └── ChatViewModel.swift    # Chat functionality
│   ├── Views/
│   │   ├── SplashView.swift
│   │   ├── SignInView.swift
│   │   ├── LoginView.swift
│   │   ├── OnboardingView.swift
│   │   ├── WelcomeView.swift
│   │   ├── HomeView.swift
│   │   ├── AthleteView.swift
│   │   ├── ChatView.swift
│   │   ├── RSVPView.swift
│   │   ├── ProfileView.swift
│   │   ├── EditProfileView.swift
│   │   ├── UserProfileView.swift
│   │   ├── SettingsView.swift
│   │   └── PrivacyPolicyView.swift
│   ├── Services/
│   │   ├── FirestoreManager.swift
│   │   ├── CacheManager.swift
│   │   ├── ImageCacheManager.swift
│   │   ├── MonitoringService.swift
│   │   ├── RateLimiter.swift
│   │   ├── InputValidator.swift
│   │   ├── AdminManager.swift
│   │   └── ProfileUpdateManager.swift
│   └── Extensions/
│       ├── Color+Extensions.swift
│       ├── Font+Inter.swift
│       ├── UIComponents+Enhanced.swift
│       └── CacheIntegration+Extensions.swift
├── Assets.xcassets/
│   └── Images/
│       └── SignacerEnhanced.imageset/
└── Resources/
    ├── AMPGIF.gif
    ├── AntGIF.gif
    ├── JJGIF.gif
    ├── PS2GIF.gif
    ├── RDCGIF.gif
    └── SeanGIF.gif
```

## Setup Instructions

### Prerequisites
- Xcode 14.0 or later
- iOS 15.0 or later
- Swift 5.7+
- CocoaPods or Swift Package Manager
- Firebase account

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd signacer
```

2. Install dependencies:
```bash
# If using CocoaPods
pod install

# If using SPM, dependencies are managed through Xcode
```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Replace the existing file in the project root
   - Enable Authentication (Email/Password and Google Sign-In)
   - Set up Cloud Firestore database
   - Configure Firebase Storage

4. Configure Google Sign-In:
   - Update `Info.plist` with your Google Client IDs
   - Add your reversed client ID to URL schemes

5. Open the project:
```bash
open signacer.xcodeproj
```

6. Build and run the project in Xcode

## Firebase Database Structure

### Collections

#### `users`
```
users/{userId}
  - uid: String
  - email: String
  - username: String
  - firstName: String
  - lastName: String
  - profilePicURL: String
  - age: Int
  - phoneNumber: String
  - bio: String
  - howDidYouHearAboutUs: String
  - participatedEvents: [String]
  - enteredGiveaways: [String]
  - votedPolls: {pollId: selectedOption}
```

#### `athletes`
```
athletes/{athleteId}
  - username: String
  - name: String
  - profilePicURL: String
  - highlightVideoURL: String
  - bio: String
  - contentURL: String
  - perks: [Perk]
  - events: [Event]
  - communities: [Community]
  - giveaways: [Giveaway]
  - polls: [Poll]
```

#### `chatRooms`
```
chatRooms/{athleteId}/messages/{messageId}
  - userId: String
  - username: String
  - message: String
  - timestamp: Date
```

#### `eventRSVPs`
```
eventRSVPs/{rsvpId}
  - eventId: String
  - athleteId: String
  - userId: String
  - name: String
  - email: String
  - numberOfGuests: Int
  - timestamp: Date
  - status: String
```

#### `giveawayEntries`
```
giveawayEntries/{entryId}
  - giveawayId: String
  - athleteId: String
  - userId: String
  - timestamp: Date
  - status: String
```

## Configuration Files

### Info.plist
Contains app configuration including:
- Custom fonts (Inter font family)
- URL schemes for Google Sign-In
- Google Client ID

### AdminConfig.plist
Administrative configuration settings for app management

## Key Features Implementation

### Authentication Flow
1. Splash screen displays on app launch
2. User directed to sign-in if not authenticated
3. Onboarding flow for new users
4. Main app navigation after completion

### Chat System
- Real-time message synchronization
- Optimistic UI updates for instant feedback
- Message status tracking
- Automatic retry for failed messages

### Caching Strategy
- Image caching for reduced network usage
- Cache invalidation and cleanup
- Performance optimization for smooth scrolling

### Monitoring & Analytics
- User action tracking
- Screen view analytics
- Performance monitoring

## Development

### Running in Debug Mode
The app includes debug-specific features:
- Font availability checking
- Detailed logging for monitoring
- Development-only UI indicators

### Building for Production
1. Update build number and version
2. Configure release signing
3. Archive and validate
4. Submit to App Store Connect

## Contributing

When contributing to this project:
1. Follow Swift style guidelines
2. Maintain MVVM architecture
3. Add appropriate error handling
4. Update documentation for new features
5. Test on multiple iOS versions

## Privacy & Security

- User data is securely stored in Firebase
- Authentication handled through Firebase Auth
- Privacy policy accessible in-app
- Input validation and sanitization
- Rate limiting for API calls

## License

[Add your license information here]

## Support

For issues or questions:
- Create an issue in the repository
- Contact the development team

## Acknowledgments

- Built with SwiftUI and Firebase
- Uses Inter font family
- Athlete GIFs and media assets in Resources/

---

Last Updated: 2025
