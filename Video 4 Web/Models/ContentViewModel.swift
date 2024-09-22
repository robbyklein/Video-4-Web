import SwiftUI
import UniformTypeIdentifiers
import AppKit
import UserNotifications

class ContentViewModel: ObservableObject {
    @Published var fileStatuses: [FileStatus] = []

    var operations: [UUID: VideoProcessingOperation] = [:]

    let ffmpegQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = max(ProcessInfo.processInfo.processorCount / 2, 1)
        queue.name = "FFmpegOperationQueue"
        return queue
    }()

    func handleDrop(providers: [NSItemProvider], videoSettings: VideoSettings) -> Bool {
        let dispatchGroup = DispatchGroup()

        for itemProvider in providers {
            dispatchGroup.enter()

            itemProvider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (data, error) in
                defer { dispatchGroup.leave() }

                if let error = error {
                    print("Error loading file URL: \(error)")
                    return
                }

                var fileURL: URL?

                if let url = data as? URL {
                    fileURL = url
                } else if let data = data as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) {
                    fileURL = url
                } else {
                    print("Invalid file URL format.")
                    return
                }

                guard let url = fileURL else { return }

                let fileExtension = url.pathExtension.lowercased()
                let fileName = url.lastPathComponent

                let fileStatus = FileStatus(fileName: fileName, status: "Queued")
                DispatchQueue.main.async {
                    self.fileStatuses.append(fileStatus)
                }

                if videoExtensions.contains(fileExtension) {
                    let operation = VideoProcessingOperation(
                        fileStatus: fileStatus,
                        url: url,
                        videoSettings: videoSettings,
                        viewModel: self
                    )

                    self.operations[fileStatus.id] = operation
                    self.ffmpegQueue.addOperation(operation)
                } else {
                    DispatchQueue.main.async {
                        fileStatus.status = "Unsupported format"
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("All files processed")
        }

        return true
    }

    /// Adds files by presenting an open panel to the user.
    /// - Parameter videoSettings: Current video settings from SettingsManager.
    func addFiles(videoSettings: VideoSettings) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true

        // Use allowedContentTypes instead of allowedFileTypes
        panel.allowedContentTypes = [
            UTType.movie,              // General movie type (covers a wide range)
            UTType(filenameExtension: "mp4")!,
            UTType(filenameExtension: "mkv")!,
            UTType(filenameExtension: "avi")!,
            UTType(filenameExtension: "mov")!,
            UTType(filenameExtension: "webm")!,
            UTType(filenameExtension: "ogv")!
        ]

        if panel.runModal() == .OK {
            let selectedFiles = panel.urls  // Capture selected file URLs
            let providers = selectedFiles.map { NSItemProvider(object: $0 as NSURL) }
            _ = handleDrop(providers: providers, videoSettings: videoSettings)
        }
    }

    func getFileSize(at url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[.size] as? NSNumber {
                return fileSize.int64Value
            }
        } catch {
            print("Error getting file size for \(url): \(error)")
        }
        return 0
    }

    func cancelOperation(for fileStatus: FileStatus) {
        if let operation = operations[fileStatus.id] {
            operation.cancel()
            DispatchQueue.main.async {
                fileStatus.status = "Cancelled"
            }
            operations.removeValue(forKey: fileStatus.id)
        }
    }

    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }

    func checkForCompletion() {
        DispatchQueue.main.async {
            if self.operations.isEmpty && self.fileStatuses.allSatisfy({ $0.isCompleted }) {
                print("All operations completed. Sending notification.")
                self.sendCompletionNotification()
            } else {
                print("Operations still in progress or statuses not completed.")
            }
        }
    }

    private func sendCompletionNotification() {
        print("Preparing to send completion notification.")
        let content = UNMutableNotificationContent()
        content.title = "Processing Queue Completed"
        content.body = "All operations completed."
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
}
