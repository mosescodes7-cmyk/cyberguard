# 🛡️ CyberGuard

**Detect. Protect. Stay aware.**

A mobile-based cyber threat detection and awareness application designed for residents, students, small businesses, and local government staff in Mbarara City, Uganda.

![Build Status](https://github.com/YOUR_USERNAME/cyberguard/workflows/Build%20Android%20APK/badge.svg)

## 👨‍💻 Developer

**AINEMBABAZI LAUBEN**  
Student ID: 23/BIT/013/UMR  
Metropolitan International University

## ✨ Features

### 🔍 Threat Detection
- **AI-Powered Scanning**: Analyzes suspicious messages and links using Groq AI (GPT-OSS-120B)
- **Local Analysis**: On-device threat detection that works offline
- **Uganda-Specific**: Detects mobile money fraud, fake bank messages, SIM swap attempts

### 🤖 AI Agent
- Cybersecurity coach available 24/7
- Provides practical advice in simple English
- Specialized in Uganda-specific threats (MTN MoMo, Airtel Money scams)

### 📊 Community Features
- Report scams and threats
- View threat map by division
- Share experiences to protect others
- Real-time community alerts

### 📚 Learning Resources
- Categorized security guides
- Best practices for digital safety
- Password and PIN management
- Mobile money safety tips

### 🔐 Security
- Firebase Authentication with phone + 6-digit PIN
- End-to-end encrypted reports
- Compliant with Data Protection and Privacy Act, 2019

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Android Studio / VS Code
- Firebase account
- Groq API key

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/cyberguard.git
cd cyberguard
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android and iOS apps
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Run Firebase configuration:
```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

4. **Run the app**
```bash
flutter run
```

## 🏗️ Build APK

### Manually
```bash
flutter build apk --release
```

The APK will be available at `build/app/outputs/flutter-apk/app-release.apk`

### Using GitHub Actions
Every push to `main` branch automatically:
- ✅ Builds the APK
- ✅ Creates a GitHub Release
- ✅ Uploads the APK as an artifact

## 🛠️ Tech Stack

- **Framework**: Flutter 3.24.0
- **Language**: Dart
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **AI/ML**: Groq API (GPT-OSS-120B model)
- **State Management**: Provider
- **Storage**: Shared Preferences
- **Media Upload**: Cloudinary

## 📱 Supported Platforms

- ✅ Android 5.0+ (API Level 21+)
- ✅ iOS 12.0+
- ✅ Web (Beta)

## 🎯 Target Users

1. **Residents** - Everyday citizens in Mbarara City
2. **Students** - University and school students
3. **Small Business Owners** - Local entrepreneurs
4. **Mobile Money Agents** - Financial service providers
5. **Local Government Staff** - Municipal workers

## 🔒 Privacy & Data Protection

- All user reports are encrypted
- Personal data is stored securely on Firebase
- Compliant with Uganda's Data Protection and Privacy Act, 2019
- No data is shared with third parties
- Users can delete their accounts and data anytime

## 🐛 Known Issues

- Device Preview (web) is enabled only in debug mode
- Some Groq API calls may fail on web due to CORS (works perfectly on mobile)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Metropolitan International University
- Mbarara City residents and businesses
- Firebase & Groq teams
- Flutter community

## 📧 Contact

**AINEMBABAZI LAUBEN**  
Metropolitan International University  
Email: [Your email]

---

**Made with ❤️ in Mbarara City, Uganda**
