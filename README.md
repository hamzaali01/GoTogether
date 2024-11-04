
# GoTogether – Mobile Application

### Overview
**GoTogether** is a social planning mobile application developed using Flutter and Firebase. The app allows users to create plans, invite friends, and manage their profiles. Built with a focus on seamless user experience, it includes features like user authentication, profile management, and a friend list, making plan creation and management easy and collaborative.

### Features
- **User Authentication**: Secure login and registration for user accounts, with Firebase authentication.
- **Profile Management**: Allows users to set up and manage their profiles.
- **Friend List**: Users can add and manage friends, simplifying the process of inviting others to plans.
- **Plan Creation**: Users can create plans and invite friends, facilitating social coordination.
- **State Management**: Utilizes BLoC for efficient data flow throughout the app.
- **Testing**: Incorporates unit and widget testing to ensure code quality and app stability.

### Technologies Used
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore for real-time data storage)
- **State Management**: BLoC (Business Logic Component)
- **Testing**: Unit and Widget Testing in Flutter

### Getting Started

#### Prerequisites
- Flutter SDK installed
- Firebase account and project set up

#### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/gotogether.git
   ```
2. Navigate to the project directory:
   ```bash
   cd gotogether
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Set up Firebase:
   - Follow the Firebase setup instructions for iOS and Android.
   - Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to their respective directories.

5. Run the app:
   ```bash
   flutter run
   ```

### Project Background
This project was developed in May 2023 to provide a platform for easy social planning and coordination. It leverages the power of Firebase and Flutter’s BLoC state management, combined with rigorous testing to ensure quality and reliability.

### Contributing
If you'd like to contribute, feel free to fork the repository and submit a pull request.
