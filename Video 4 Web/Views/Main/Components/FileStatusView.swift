import SwiftUI

struct FileStatusView: View {
    @ObservedObject var fileStatus: FileStatus

    var body: some View {
        HStack {
            Text(fileStatus.fileName)
            Spacer()
            Text(fileStatus.status)
                .foregroundColor(statusColor(for: fileStatus.status))
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "Completed":
            return .green
        case "Processing":
            return .blue
        case "Queued":
            return .gray
        case "Failed", "Unsupported format":
            return .red
        default:
            return .black
        }
    }
}
