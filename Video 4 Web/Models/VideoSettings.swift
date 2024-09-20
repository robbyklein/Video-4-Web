import SwiftUI

class VideoSettings: ObservableObject {
    @AppStorage("compressionLevel") var compressionLevel: String = "Medium"
    @AppStorage("removeAudio") var removeAudio: Bool = true
    @AppStorage("mp4OutputFormat") var mp4OutputFormat: Bool = true
    @AppStorage("webmOutputFormat") var webmOutputFormat: Bool = true
    @AppStorage("selectedScale") var selectedScale: String = "Do not scale"

    let scaleOptions = [
        "Do not scale",
        "Scale to 1920 width",
        "Scale to 1680 width",
        "Scale to 1600 width",
        "Scale to 1440 width",
        "Scale to 1400 width",
        "Scale to 1280 width",
        "Scale to 1024 width",
        "Scale to 960 width",
        "Scale to 800 width",
        "Scale to 720 width",
        "Scale to 640 width",
        "Scale to 576 width",
        "Scale to 480 width",
        "Scale to 320 width",
        "Scale to 240 width",
        "Scale to 160 width"
    ]

    let compressionLevels = [
        "Low",
        "Medium",
        "High"
    ]
}
