# Imager 2 - Text Extractor iOS App

A powerful iOS text extraction and document management app built with SwiftUI.

**Created by:** speedyfriend67  
**Contact:** speedyfriend433@gmail.com

## Features

**Core Functionality:**
- Text extraction from images
- Voice-to-text input
- Multiple language support
- Text formatting options
- Document version history

**Document Management:**
- Create and edit documents
- Auto-save functionality
- Local storage
- Document statistics
- Version control

**Text Formatting:**
- Font size adjustment
- Line spacing control
- Multiple font families
- Text alignment options
- Spell checking

**Export & Sharing:**
- PDF export
- Document sharing
- Copy to clipboard
- Quick statistics view

## Screenshots

![A7981B97-4023-4352-AE95-04CC3EE71827](https://github.com/user-attachments/assets/6fb6d3ee-9bc2-4c40-b73f-f162690307e8)


## Requirements

- iOS 14.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository
```bash
git clone https://github.com/speedyfriend67/imager2-Revive-SwiftUI.git
Open the project in Xcode
cd imager2-Revive-SwiftUI
open imager2.xcodeproj
Build and run the project
Required Permissions
Add these keys to your Info.plist:

<key>NSCameraUsageDescription</key>
<string>We need camera access to scan text from images</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images for text extraction</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>We need access to speech recognition to convert your voice to text</string>

<key>NSMicrophoneUsageDescription</key>
<string>We need access to the microphone to record your voice</string>```


## Project Structure

imager2/
├── imager2.swift
├── ContentView.swift
├── Models/
│   ├── LocalDocument.swift
│   ├── TextFormattingOptions.swift
│   └── RecognitionLanguage.swift
├── Views/
│   ├── MainViews/
│   │   ├── HomeView.swift
│   │   ├── DocumentListView.swift
│   │   └── TextEditorView.swift
│   ├── Components/
│   │   ├── ImageButtonView.swift
│   │   ├── ShareSheet.swift
│   │   ├── ImagePicker.swift
│   │   └── CameraView.swift
├── Services/
│   ├── TextRecognitionService.swift
│   ├── LocalStorageManager.swift
│   └── LanguageDetectionService.swift
└── Utils/
    └── TextFormatter.swift


## Key Components

# Models
- LocalDocument: Document data structure
- TextFormattingOptions: Text formatting settings
- RecognitionLanguage: Supported languages
# Views
- TextEditorView: Main document editing interface
- DocumentListView: Document management
- ImagePicker: Image selection for text extraction
- CameraView: Camera interface for text scanning
# Services
- LocalStorageManager: Document persistence
- TextRecognitionService: Image-to-text conversion
- LanguageDetectionService: Language detection and handling

## Usage Examples

# Creating a New Document

```let document = LocalDocument(
    title: "New Document",
    content: "Your content here",
    language: "en-US"
)```

# Text Formatting

```document.formattingOptions.fontSize = 16
document.formattingOptions.fontFamily = "Helvetica"
document.formattingOptions.lineSpacing = 1.2```

## Contributing

- Fork the repository
- Create your feature branch (git checkout -b feature/AmazingFeature)
- Commit your changes (git commit -m 'Add some AmazingFeature')
- Push to the branch (git push origin feature/AmazingFeature)
- Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

- SwiftUI framework
- Vision framework for text recognition
- Speech framework for voice input

## Contact

speedyfriend67 - speedyfriend433@gmail.com

## Project Link: https://github.com/speedyfriend67/imager2-Revive-SwiftUI

## Future Enhancements
 - Cloud sync functionality []
 - Advanced text formatting options []
 - Multiple language translation []
 - Markdown support []
 - Custom themes []
 - Search functionality []
 - Tags and categories []
 - Collaborative editing []
