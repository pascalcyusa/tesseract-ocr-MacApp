# MacOCR - Native macOS Tesseract OCR App

A lightweight, native macOS menu bar application that uses the Tesseract OCR engine to recognize text from any part of your screen.

## Features
- **Lightweight**: Native Swift app with minimal footprint.
- **Menu Bar App**: Lives in your menu bar, out of the way.
- **Global Shortcut**: Press `Cmd+Shift+E` to capture and recognize text instantly.
- **Clipboard Integration**: Automatically copies recognized text to your clipboard.
- **Native UI**: Built with SwiftUI and AppKit.

## Prerequisites

You need **Xcode** installed on your Mac.

You also need **Homebrew** to install the Tesseract and Leptonica libraries.

## Setup Instructions

### 1. Install Dependencies

Open Terminal and run:
```bash
brew install tesseract leptonica
```
This installs the OCR engine and the image processing library.

### 2. Create the Xcode Project

1.  Open Xcode and create a new project.
2.  Select **macOS** -> **App**.
3.  Product Name: `MacOCR` (or whatever you like).
4.  Interface: **SwiftUI**.
5.  Language: **Swift**.
6.  Save the project.

### 3. Add Source Files

1.  Copy the `macos_app` folder (the one containing this README) to your project directory.
2.  In Xcode, right-click on the project navigator (left sidebar) and select **"Add Files to 'MacOCR'..."**.
3.  Select the following files from the `macos_app` folder:
    - `TesseractWrapper.h`
    - `TesseractWrapper.mm`
    - `MacOCRApp.swift` (replace the existing one or rename/delete the default one created by Xcode)
    - `AppDelegate.swift`
    - `CaptureManager.swift`
    - `ContentView.swift`
    - `SettingsView.swift`
    - `MacOCRApp-Bridging-Header.h` (you can add this, but we'll configure it in settings)
4.  **Important**: When adding `TesseractWrapper.mm`, Xcode might ask "Would you like to configure an Objective-C bridging header?".
    - If it asks, click **"Create Bridging Header"**.
    - If it doesn't ask, you will set it manually (see step 5).

### 4. Configure Build Settings

Click on your project in the left sidebar, then select the **Target** (MacOCR). Go to the **Build Settings** tab.

**A. Header Search Paths**
Search for "Header Search Paths" and add the following (non-recursive):
- `/opt/homebrew/include` (for Apple Silicon)
- `/usr/local/include` (for Intel Macs)

**B. Library Search Paths**
Search for "Library Search Paths" and add:
- `/opt/homebrew/lib` (for Apple Silicon)
- `/usr/local/lib` (for Intel Macs)

**C. Other Linker Flags**
Search for "Other Linker Flags" and add:
- `-ltesseract`
- `-lleptonica`

**D. Objective-C Bridging Header**
If Xcode didn't create one for you:
Search for "Objective-C Bridging Header".
Set the value to the path of `MacOCRApp-Bridging-Header.h`.
Example: `MacOCR/MacOCRApp-Bridging-Header.h` (relative to project root).
**Or**, if Xcode created `MacOCR-Bridging-Header.h`, open it and add:
```objective-c
#import "TesseractWrapper.h"
```

**E. C++ Language Dialect**
Search for "C++ Language Dialect" and ensure it is set to **C++17** or **GNU++17** (Tesseract requires modern C++).

### 5. Configure Signing & Capabilities

1.  Go to the **Signing & Capabilities** tab.
2.  **App Sandbox**:
    - For this app to capture the screen and run external commands (`screencapture`), it is easiest to **disable App Sandbox** during development. Click the "x" to remove the App Sandbox capability.
    - *Alternatively*, if you keep Sandbox enabled, you must add the `com.apple.security.temporary-exception.mach-lookup.global-name` entitlement for `com.apple.screencapture` and ensure you have `Hardware -> Camera` usage description in Info.plist (though `screencapture` CLI usually handles its own permissions). Disabling sandbox is recommended for a personal developer tool.
3.  **Hardened Runtime**:
    - If you encounter issues loading the Homebrew libraries (code signature errors), you may need to **Disable Library Validation** in Hardened Runtime settings.

### 6. Info.plist

Open `Info.plist` (or the Info tab in Target settings) and add:
- **Privacy - AppleEvents Sending Usage Description**: "This app needs to control screen capture." (Optional, but good practice).

### 7. Run

1.  Build and Run (Cmd+R).
2.  The app will appear in the menu bar (a small text/viewfinder icon).
3.  Press **Cmd+Shift+E**.
4.  The cursor will change to a crosshair. Select an area on the screen.
5.  Wait a moment. If text is found, you'll hear a sound and the text will be in your clipboard!

## Troubleshooting

- **"Library not found for -ltesseract"**: Check your "Library Search Paths". Verify `brew info tesseract` shows where it is installed.
- **"Tesseract/baseapi.h file not found"**: Check your "Header Search Paths".
- **"Failed to initialize Tesseract"**: Make sure you have `tesseract` installed via brew. The app looks for trained data in `/opt/homebrew/share/tessdata`.
- **Global Hotkey not working**: Make sure the app has accessibility permissions if using non-Carbon methods, but the Carbon method used here should work. If not, check if another app uses `Cmd+Shift+E`.

## Customization

- To change the hotkey, edit `AppDelegate.swift` in `registerHotKey()`.
- To change language, edit `TesseractWrapper.mm` (currently set to "eng").
