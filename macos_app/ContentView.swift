import SwiftUI

struct ContentView: View {
    @ObservedObject var captureManager = CaptureManager.shared

    var body: some View {
        VStack {
            Text("MacOCR")
                .font(.headline)
                .padding(.top)

            Divider()

            ScrollView {
                Text(captureManager.lastRecognizedText)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled) // Allow text selection
            }
            .frame(height: 200)

            Divider()

            HStack {
                Button("Capture") {
                    captureManager.captureAndRecognize()
                }
                .disabled(captureManager.isProcessing)

                Spacer()

                Button(action: {
                    // Try to open the settings window
                    if !NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }) {
                    Image(systemName: "gear")
                }
                .buttonStyle(.borderless)
                .help("Preferences")

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        }
        .frame(width: 300, height: 300)
    }
}
