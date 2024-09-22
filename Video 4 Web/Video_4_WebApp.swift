import SwiftUI

@main
struct Video4WebApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var windowManager = WindowManager()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var viewModel = ContentViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(windowManager)
                .environmentObject(settingsManager)
                .environmentObject(viewModel)
                .frame(minWidth: 560, minHeight: 360)
                .onAppear {
                    viewModel.requestNotificationPermission()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
                    for operation in viewModel.operations.values {
                        operation.terminateAllFFmpegTasks()
                    }
                }
        }
        .windowResizability(.contentMinSize)
        .commands {
            // Video 4 Web
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    windowManager.openSettingsWindow(settingsManager: settingsManager)
                }
                .keyboardShortcut(",", modifiers: .command)
            }

            CommandGroup(replacing: .appInfo) {
                Button("About Video 4 Web") {
                    windowManager.openAboutWindow()
                }
            }

            // File
            CommandGroup(after: .newItem) {
                Button("Add Files") {
                    viewModel.addFiles(videoSettings: settingsManager.videoSettings)
                }
                .keyboardShortcut("O", modifiers: .command)
            }

            // Help
            CommandGroup(after: .help) {
                Divider()
                Button("View Source") {
                    if let url = URL(string: "https://github.com/robbyklein/Video-4-Web") {
                        NSWorkspace.shared.open(url)
                    }
                }

                Button("Video 4 Web Website") {
                    if let url = URL(string: "https://video4web.robbyk.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
}
