import Foundation
import SwiftUI

class FFmpegOperation: Operation, @unchecked Sendable {
    let inputURL: URL
    let fileStatus: FileStatus
    let videoSettings: VideoSettings
    let scaleOptions: [String: String]

    private var isOperationExecuting = false
    private var isOperationFinished = false

    override var isAsynchronous: Bool {
        return true
    }

    override private(set) var isExecuting: Bool {
        get { isOperationExecuting }
        set {
            willChangeValue(forKey: "isExecuting")
            isOperationExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    override private(set) var isFinished: Bool {
        get { isOperationFinished }
        set {
            willChangeValue(forKey: "isFinished")
            isOperationFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    init(
        inputURL: URL,
        fileStatus: FileStatus,
        videoSettings: VideoSettings,
        scaleOptions: [String: String]
    ) {
        self.inputURL = inputURL
        self.fileStatus = fileStatus
        self.videoSettings = videoSettings
        self.scaleOptions = scaleOptions
        super.init()
    }

    override func start() {
        if isCancelled {
            finish()
            return
        }

        isExecuting = true

        DispatchQueue.main.async {
            self.fileStatus.status = "Processing"
        }

        // Run FFmpeg
        let options = RunFFmpegOptions(
            inputURL: self.inputURL,
            compressionLevel: self.videoSettings.compressionLevel,
            removeAudio: self.videoSettings.removeAudio,
            selectedScale: self.videoSettings.selectedScale,
            mp4OutputFormat: self.videoSettings.mp4OutputFormat,
            webmOutputFormat: self.videoSettings.webmOutputFormat
        )

        VideoProcessor.runFFmpeg(options: options) { success, message, outputPaths in
            DispatchQueue.main.async {
                if success {
                    // Compute sizes and savings
                    let inputSize = self.getFileSize(at: self.inputURL)
                    let outputSizes = outputPaths.values.map { self.getFileSize(at: URL(fileURLWithPath: $0)) }
                    let totalOutputSize = outputSizes.reduce(0, +)
                    let savings = inputSize - totalOutputSize
                    self.fileStatus.newSize = totalOutputSize
                    self.fileStatus.savings = savings
                    self.fileStatus.status = "Completed"
                } else {
                    self.fileStatus.status = "Failed"
                    print("Error processing file \(self.fileStatus.fileName): \(message)")
                }
                self.finish()
            }
        }
    }

    private func finish() {
        isExecuting = false
        isFinished = true
    }

    private func getFileSize(at url: URL) -> Int64 {
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
}
