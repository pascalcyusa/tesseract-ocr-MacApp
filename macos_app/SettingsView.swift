import SwiftUI

struct SettingsView: View {
    @AppStorage("playSound") private var playSound = true
    // Launch at login implementation requires specific API calls (SMAppService)
    // For this lightweight version, we just show the toggle as a placeholder/example.
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Toggle("Play sound on success", isOn: $playSound)

            // Note: Functional "Launch at Login" requires adding a helper app or using SMAppService (macOS 13+)
            // This toggle just stores the preference for now.
            Toggle("Launch at login", isOn: $launchAtLogin)

            Text("Global Shortcut: Cmd+Shift+E")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
        .frame(width: 350, height: 150)
    }
}
