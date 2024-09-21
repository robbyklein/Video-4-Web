import SwiftUI
import AppKit

class WindowManager: ObservableObject {
    @Published var settingsWindow: NSWindow?
    @Published var aboutWindow: NSWindow?

    func openSettingsWindow(settingsManager: SettingsManager) {
        let settingsView = NSHostingController(rootView: SettingsView()
            .environmentObject(settingsManager)
        )

        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentViewController: settingsView
            )
            settingsWindow?.setContentSize(NSSize(width: 400, height: 320))
            settingsWindow?.title = "Settings"
            settingsWindow?.styleMask.remove(.resizable)
        }

        positionWindow(window: settingsWindow)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    func openAboutWindow() {
        let aboutView = NSHostingController(rootView: AboutView())

        if aboutWindow == nil {
            aboutWindow = NSWindow(
                contentViewController: aboutView
            )
            aboutWindow?.setContentSize(NSSize(width: 400, height: 275))
            aboutWindow?.title = "About Video 4 Web"
            aboutWindow?.styleMask.remove(.resizable)
        }

        positionWindow(window: aboutWindow)
        aboutWindow?.makeKeyAndOrderFront(nil)
    }

    private func positionWindow(window: NSWindow?) {
        if let mainWindow = NSApplication.shared.windows.first, let window = window {
            let mainFrame = mainWindow.frame
            let windowSize = window.frame.size
            let windowX = mainFrame.midX - (windowSize.width / 2)
            let windowY = mainFrame.midY - (windowSize.height / 2)
            window.setFrame(
                NSRect(x: windowX, y: windowY, width: windowSize.width, height: windowSize.height),
                display: true
            )
        }
    }
}
