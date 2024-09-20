import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        VStack(spacing: 25) {
            // Compression level
            VStack(alignment: .leading, spacing: 15) {
                SettingLabel(text: "Compression Level", icon: "arrow.up.arrow.down")
                Picker("Compression Level", selection: $settingsManager.videoSettings.compressionLevel) {
                    ForEach(settingsManager.videoSettings.compressionLevels, id: \.self) {
                        Text($0)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }

            // Output formats
            VStack(alignment: .leading, spacing: 15) {
                SettingLabel(text: "Output Formats", icon: "square.and.arrow.up")
                HStack(spacing: 20) {
                    Toggle("MP4", isOn: $settingsManager.videoSettings.mp4OutputFormat)
                    Toggle("WebM", isOn: $settingsManager.videoSettings.webmOutputFormat)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)

            // Scaling
            VStack(alignment: .leading, spacing: 15) {
                SettingLabel(text: "Scale", icon: "square.resize.down")
                Picker("Scale", selection: $settingsManager.videoSettings.selectedScale) {
                    ForEach(settingsManager.videoSettings.scaleOptions, id: \.self) {
                        Text($0)
                    }
                }
                .labelsHidden()
            }

            // Remove audio
            VStack(alignment: .leading, spacing: 15) {
                SettingLabel(text: "Remove Audio", icon: "speaker.slash")
                Toggle("Yes", isOn: $settingsManager.videoSettings.removeAudio)
                    .padding(.bottom, 20)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

struct SettingLabel: View {
    var text: String
    var icon: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
            Text(text)
                .font(.headline)
                .fontWeight(.medium)
        }
    }
}
