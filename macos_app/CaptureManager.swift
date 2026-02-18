import Cocoa
import SwiftUI
import AppKit

class CaptureManager: ObservableObject {
    static let shared = CaptureManager()

    // Published properties for UI updates
    @Published var lastRecognizedText: String = "Ready to scan..."
    @Published var isProcessing: Bool = false

    private var wrapper: TesseractWrapper?

    init() {
        self.wrapper = TesseractWrapper()
        if self.wrapper == nil {
            self.lastRecognizedText = "Error: Tesseract failed to initialize. Ensure traineddata is installed."
        }
    }

    // Perform capture and recognition
    func captureAndRecognize() {
        guard !isProcessing else { return }

        if wrapper == nil {
            // Try to initialize again
             self.wrapper = TesseractWrapper()
             if self.wrapper == nil {
                 self.lastRecognizedText = "Error: Tesseract not initialized."
                 return
             }
        }

        isProcessing = true
        lastRecognizedText = "Select an area on screen..."

        // Run on background queue to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            self.performCapture()
        }
    }

    private func performCapture() {
        // Clear clipboard to avoid reading old data
        DispatchQueue.main.sync {
            NSPasteboard.general.clearContents()
        }

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-c"] // Interactive selection, copy to clipboard

        do {
            try task.run()
            task.waitUntilExit()

            if task.terminationStatus == 0 {
                // Capture successful, read from clipboard
                DispatchQueue.main.async {
                    self.processClipboardImage()
                }
            } else {
                // User cancelled or error
                DispatchQueue.main.async {
                    self.lastRecognizedText = "Capture cancelled."
                    self.isProcessing = false
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.lastRecognizedText = "Failed to launch capture: \(error.localizedDescription)"
                self.isProcessing = false
            }
        }
    }

    private func processClipboardImage() {
        // Read image from clipboard
        guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            self.lastRecognizedText = "No image found in clipboard."
            self.isProcessing = false
            return
        }

        self.lastRecognizedText = "Processing..."

        // Run OCR on background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let text = self.wrapper?.recognizeImage(image)

            DispatchQueue.main.async {
                if let text = text, !text.isEmpty {
                    let cleanedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.lastRecognizedText = cleanedText

                    // Copy result back to clipboard
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(cleanedText, forType: .string)

                    // Play success sound if enabled
                    if UserDefaults.standard.bool(forKey: "playSound") {
                        NSSound(named: "Glass")?.play()
                    }
                } else {
                    self.lastRecognizedText = "No text recognized."
                }
                self.isProcessing = false
            }
        }
    }
}
