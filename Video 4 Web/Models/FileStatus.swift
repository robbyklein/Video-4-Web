import SwiftUI

class FileStatus: ObservableObject, Identifiable {
    @Published var status: String
    @Published var originalSize: Int64 = 0
    @Published var newSize: Int64 = 0
    @Published var savings: Int64 = 0

    let id = UUID()
    let fileName: String

    init(fileName: String, status: String) {
        self.fileName = fileName
        self.status = status
    }

    var originalSizeFormatted: String {
        formatSize(originalSize)
    }

    var newSizeFormatted: String {
        formatSize(newSize)
    }

    var savingsFormatted: String {
        if originalSize > 0 {
            let percentage = Double(savings) / Double(originalSize) * 100
            return String(format: "%.1f%%", percentage)
        } else {
            return "0%"
        }
    }

    private func formatSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
