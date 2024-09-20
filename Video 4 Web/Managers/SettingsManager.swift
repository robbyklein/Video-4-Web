import SwiftUI

class SettingsManager: ObservableObject {
    @Published var videoSettings = VideoSettings()
}
