import SwiftUI

struct DropZoneView: View {
    @Binding var isTargeted: Bool
    @Environment(\.colorScheme) var colorScheme

    private var borderColor: Color {
        if isTargeted {
            return colorScheme == .dark ? Color.white.opacity(0.4) : Color.black.opacity(0.4)
        } else {
            return colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.15)
        }
    }

    private var contentColor: Color {
        if isTargeted {
            return colorScheme == .dark ? Color.white.opacity(0.55) : Color.black.opacity(0.55)
        } else {
            return colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)
        }
    }

    var body: some View {
        ZStack {
            Color.clear
                .background(BlurView())
                .edgesIgnoringSafeArea(.all)

            // Drop zone content
            VStack(spacing: 10) {
                Image(systemName: "arrow.down")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(contentColor)

                Text("Drop Video Files")
                    .foregroundColor(contentColor)
                    .padding(10)
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Overlay with adaptive border color
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 3, dash: [11]))
                .foregroundColor(borderColor)
                .padding(20)
        )
        // Remove the `.onDrop` modifier from here
    }
}

// SwiftUI BlurView for macOS
struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    }
}

// Preview for testing
struct ContentView: View {
    var body: some View {
        DropZoneView(isTargeted: .constant(false))
    }
}
