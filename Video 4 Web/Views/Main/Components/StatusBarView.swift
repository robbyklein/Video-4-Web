import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct StatusBarView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var windowManager: WindowManager
    @EnvironmentObject var viewModel: ContentViewModel // Use shared ViewModel

    @Environment(\.colorScheme) var colorScheme  // Access the current color scheme

    var body: some View {
        VStack(spacing: 0) {  // Set spacing to 0 to eliminate gaps
            HStack {
                // File selector button
                Button(
                    action: {
                        viewModel.addFiles(videoSettings: settingsManager.videoSettings)
                    },
                    label: {
                        Image(systemName: "filemenu.and.cursorarrow")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(.primary)
                    }
                )
                .buttonStyle(PlainButtonStyle())
                .padding(.leading)

                Spacer().frame(width: 20)

                VStack(alignment: .leading, content: {
                    Text("Compression")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                        .textCase(.uppercase)
                        .font(.system(size: 9, weight: .medium))
                        .opacity(0.65)
                    Spacer().frame(height: 3)
                    Text("\(settingsManager.videoSettings.compressionLevel)")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                })

                Spacer().frame(width: 10)

                VStack(alignment: .leading, content: {
                    Text("Audio")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                        .textCase(.uppercase)
                        .font(.system(size: 9, weight: .medium))
                        .opacity(0.65)
                    Spacer().frame(height: 3)
                    Text("\(settingsManager.videoSettings.removeAudio ? "Remove" : "Keep")")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                })

                Spacer().frame(width: 10)

                VStack(alignment: .leading, content: {
                    Text("Scale")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                        .textCase(.uppercase)
                        .font(.system(size: 9, weight: .medium))
                        .opacity(0.65)
                    Spacer().frame(height: 3)
                    Text("\(settingsManager.videoSettings.selectedScale)")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                })

                Spacer().frame(width: 10)

                VStack(alignment: .leading, content: {
                    Text("Formats")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                        .textCase(.uppercase)
                        .font(.system(size: 9, weight: .medium))
                        .opacity(0.65)
                    Spacer().frame(height: 3)
                    Text("\(selectedFormats)")
                        .foregroundColor(.secondary)
                        .padding(.leading)
                })

                Spacer()

                // Settings button
                Button(
                    action: {
                        windowManager.openSettingsWindow(settingsManager: settingsManager)
                    },
                    label: {
                        Image(systemName: "gearshape")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                    }
                )
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing)
            }
            .frame(height: 60)
            // Apply the gradient background
            .background(
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            // Add the top border
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(borderColor),
                alignment: .top
            )
        }
    }

    // Computed property for gradient colors based on color scheme
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [Color(hex: "#323232"), Color(hex: "#2A2A2A")]
        } else {
            return [Color(hex: "#EBEBEB"), Color(hex: "#D4D4D4")]
        }
    }

    // Computed property for border color based on color scheme
    private var borderColor: Color {
        if colorScheme == .dark {
            return Color(hex: "#000000")
        } else {
            return Color(hex: "#C6C6C6")
        }
    }

    // Utility to display selected formats
    private var selectedFormats: String {
        var formats = [String]()

        if settingsManager.videoSettings.mp4OutputFormat {
            formats.append("MP4")
        }

        if settingsManager.videoSettings.webmOutputFormat {
            formats.append("WebM")
        }

        return formats.isEmpty ? "None" : formats.joined(separator: ", ")
    }
}
