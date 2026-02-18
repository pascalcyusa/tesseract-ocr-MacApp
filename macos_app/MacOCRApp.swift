import SwiftUI

@main
struct MacOCRApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // This adds a "Preferences..." menu item to the app menu
        Settings {
            SettingsView()
        }
    }
}
