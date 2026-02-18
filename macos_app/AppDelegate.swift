import Cocoa
import SwiftUI
import Carbon

// Global hotkey handler function (C convention)
func hotKeyHandler(nextHandler: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    // Notify the app on main thread
    DispatchQueue.main.async {
        CaptureManager.shared.captureAndRecognize()
    }
    return noErr
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var eventHandler: EventHandlerRef?
    var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register user defaults
        UserDefaults.standard.register(defaults: ["playSound": true])

        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "OCR")
            button.action = #selector(togglePopover(_:))
        }

        // Create the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 350) // Updated size
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ContentView())

        // Register global hotkey (Cmd+Shift+E)
        registerHotKey()
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                // Make app active
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    func registerHotKey() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        // Install handler
        let status = InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &eventType, nil, &eventHandler)
        if status != noErr {
            print("Failed to install event handler: \(status)")
            return
        }

        // Register Cmd+Shift+E
        // 'OCR!' signature
        let hotKeyID = EventHotKeyID(signature: 0x4F435221, id: 1)

        // cmdKey (256) | shiftKey (512)
        // kVK_ANSI_E = 0x0E (14)
        let modifiers = UInt32(cmdKey | shiftKey)
        let key = UInt32(kVK_ANSI_E)

        let regStatus = RegisterEventHotKey(key, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        if regStatus != noErr {
            print("Failed to register hotkey: \(regStatus)")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Unregister hotkey if needed (OS cleans up usually)
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
}
