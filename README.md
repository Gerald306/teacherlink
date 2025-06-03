# Teacher Connect Uganda 🇺🇬

A modern mobile application connecting teachers with schools across Uganda. Built with Flutter and Firebase, featuring a beautiful UI design inspired by Uganda's natural beauty.

## 🌟 Features

### For Teachers
- **Profile Management**: Create comprehensive profiles with qualifications, subjects, and skills
- **Job Search**: Browse and filter job opportunities by location, subjects, and job type
- **Application Tracking**: Monitor application status and receive updates
- **Premium Subscriptions**: Access to premium features and priority job listings
- **Document Upload**: Upload certificates and CV for verification

### For Schools
- **School Profiles**: Create detailed school profiles with facilities and information
- **Job Posting**: Post job opportunities with detailed requirements
- **Teacher Search**: Find qualified teachers based on specific criteria
- **Application Management**: Review and manage teacher applications

### For Admins
- **User Management**: Verify teachers and schools
- **Platform Analytics**: Monitor platform usage and statistics
- **Content Moderation**: Ensure quality and appropriate content

## 🎨 Design Features

- **Uganda-Inspired Theme**: Forest green and golden yellow color palette
- **Material 3 Design**: Modern, responsive UI components
- **Smooth Animations**: Fade, slide, and scale transitions
- **Responsive Layout**: Optimized for both Android and iOS devices
- **Professional Typography**: Google Fonts (Poppins) for readability

## 💳 Payment Integration

- **Mobile Money Support**: MTN Mobile Money and Airtel Money
- **Local Pricing**: Subscription plans in Ugandan Shillings (UGX)
- **Flexible Plans**: Basic (10,000 UGX), Premium (25,000 UGX), Annual (200,000 UGX)

## 🛠 Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **State Management**: Provider
- **UI Components**: Custom Material 3 widgets
- **Image Handling**: Image Picker
- **Local Storage**: Shared Preferences
- **Notifications**: Flutter Local Notifications

## 📱 Live Demo

### 🌐 Interactive Web Demo
Experience the full app functionality with our interactive web demo:

**🔗 [View Live Demo](web_demo/index.html)**

**Features Demonstrated:**
- ✅ **Login & Signup Flow** - Complete authentication experience
- ✅ **Teacher Registration** - Role selection and profile setup
- ✅ **Job Search & Applications** - Browse and apply for teaching positions
- ✅ **Premium Subscriptions** - Mobile money payment integration
- ✅ **Profile Management** - Skills, subjects, and experience setup
- ✅ **Admin Dashboard** - Platform analytics and management tools

**How to Use:**
1. Open `web_demo/index.html` in your browser
2. Navigate between screens using the top buttons
3. Test interactive features like role selection and payment flow
4. Experience the complete user journey from signup to job application

### 📱 Screenshots

*Screenshots will be added once the Flutter app is running*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=2.17.0)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/teacher-connect-uganda.git
   cd teacher-connect-uganda
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication, Firestore, and Storage
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

4. **Configure Firebase**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Initialize Firebase in your project
   firebase init
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── teacher_profile.dart
│   ├── school_profile.dart
│   └── job_posting.dart
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── teacher/             # Teacher-specific screens
│   ├── school/              # School-specific screens
│   ├── admin/               # Admin screens
│   └── payment/             # Payment screens
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── teacher_service.dart
│   ├── job_service.dart
│   └── payment_service.dart
├── widgets/                  # Reusable UI components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── ...
└── theme/                    # App theming
    └── app_theme.dart
```

## 🔧 Configuration

### Firebase Rules

**Firestore Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Teachers collection
    match /teachers/{teacherId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == teacherId;
    }
    
    // Schools collection
    match /schools/{schoolId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == schoolId;
    }
    
    // Jobs collection
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Applications collection
    match /applications/{applicationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

**Storage Security Rules:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /certificates/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Developer**: [Your Name]
- **Designer**: [Designer Name]
- **Project Manager**: [PM Name]

## 📞 Support

For support, email support@teacherconnectuganda.com or join our Slack channel.

## 🗺 Roadmap

- [ ] **Phase 1**: Core functionality (✅ Completed)
- [ ] **Phase 2**: Advanced features
  - [ ] Video interviews
  - [ ] Skill assessments
  - [ ] Recommendation system
- [ ] **Phase 3**: Platform expansion
  - [ ] Web application
  - [ ] API for third-party integrations
  - [ ] Multi-language support

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Uganda's education sector for inspiration
- All contributors and testers

---

**Made with ❤️ for Uganda's education sector**
