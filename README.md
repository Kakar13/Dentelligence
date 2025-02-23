![Static Badge](https://img.shields.io/badge/Platform-iOS_%7C_macOS-blue)

# HackAI2025

HackAI2025 is a dental treatment management application that allows healthcare professionals to record patient treatments, generate reports, and manage audio recordings of patient interactions. The app leverages AVFoundation for audio recording and Whisper for transcription, providing a seamless experience for dental professionals.

## Features

- **Audio Recording**: Record patient interactions and treatments using AVFoundation.
- **Transcription**: Automatically transcribe audio recordings using Whisper.
- **PDF Generation**: Generate detailed treatment reports in PDF format.
- **Patient Management**: Store and manage patient information and treatment history.
- **User-Friendly Interface**: Intuitive UI built with SwiftUI for easy navigation.

## Installation

To get started with HackAI2025, follow these steps:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Kakar13/hackai-2025.git
   ```

2. **Navigate to the project directory**:
   ```bash
   cd HackAI2025
   ```

3. **Open the project in Xcode**:
   ```bash
   open HackAI2025.xcodeproj
   ```

4. **Install dependencies**:
   Ensure that required dependencies are installed using Swift Package Manager or CocoaPods, as specified in the project.

5. **Run the app**:
   Select a simulator or a physical device and click the run button in Xcode.

## Usage

1. **Create a New Report**: Navigate to the "New Report" section to enter patient details and start recording.
2. **Record Audio**: Use the microphone button to start and stop audio recordings.
3. **View Reports**: After generating a report, you can view it in the "Reports" section.
4. **Share Reports**: Share generated PDFs via email or other sharing options.

## Contributing

Contributions are welcome! If you would like to contribute to HackAI2025, please follow these steps:

1. **Fork the repository**.
2. **Create a new branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/YourFeature
   ```
3. **Make your changes** and commit them:
   ```bash
   git commit -m "Add some feature"
   ```
4. **Push to the branch**:
   ```bash
   git push origin feature/YourFeature
   ```
5. **Open a pull request**.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [AVFoundation](https://developer.apple.com/documentation/avfoundation) for audio recording capabilities.
- [Whisper](https://github.com/exPHAT/SwiftWhisper) for transcription services.
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for building the user interface.
