import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct MainView: View {
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var viewModel: ContentViewModel
    @State private var isTargeted: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.fileStatuses.isEmpty {
                DropZoneView(isTargeted: $isTargeted).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                FilesListView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Ensure the status bar is placed at the bottom
            StatusBarView()
                .frame(height: 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Handle the drop in `MainView`
        .onDrop(
            of: ["public.file-url"],
            isTargeted: $isTargeted
        ) { providers in
            // Call your viewModel's drop handler
            _ = viewModel.handleDrop(
                providers: providers,
                videoSettings: settingsManager.videoSettings
            )
            return true // Return true to accept the drop
        }
    }
}
