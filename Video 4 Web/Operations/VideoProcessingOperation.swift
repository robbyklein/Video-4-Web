import Foundation
import SwiftUI

class VideoProcessingOperation: AsyncOperation, @unchecked Sendable {
    private let fileStatus: FileStatus
    private let url: URL
    private let videoSettings: VideoSettings
    private let viewModel: ContentViewModel

    var ffmpegTasks: [Process] = []
    var outputPaths: [String] = []
    var outputInfo: [(format: String, path: String)] = []

    init(
        fileStatus: FileStatus,
        url: URL,
        videoSettings: VideoSettings,
        viewModel: ContentViewModel
    ) {
        self.fileStatus = fileStatus
        self.url = url
        self.videoSettings = videoSettings
        self.viewModel = viewModel
        super.init()
    }

    override func main() {
        if isCancelled {
            handleCancellation()
            return
        }

        updateStatusToProcessing()
        prepareOutputPaths()

        let dispatchGroup = DispatchGroup()
        var encounteredError = false

        for output in outputInfo {
            dispatchGroup.enter()
            processOutput(output, dispatchGroup: dispatchGroup) { success in
                if !success {
                    encounteredError = true
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.handleCompletion(encounteredError: encounteredError)
        }
    }

    private func handleCancellation() {
        DispatchQueue.main.async {
            self.fileStatus.status = "Cancelled"
        }
        self.cleanupOutputFiles()
        self.finish()
    }

    private func updateStatusToProcessing() {
        DispatchQueue.main.async {
            self.fileStatus.status = "Processing"
        }
        let inputSize = viewModel.getFileSize(at: url)
        DispatchQueue.main.async {
            self.fileStatus.originalSize = inputSize
        }
    }

    private func prepareOutputPaths() {
        let options = RunFFmpegOptions(
            inputURL: url,
            compressionLevel: videoSettings.compressionLevel,
            removeAudio: videoSettings.removeAudio,
            selectedScale: videoSettings.selectedScale,
            mp4OutputFormat: videoSettings.mp4OutputFormat,
            webmOutputFormat: videoSettings.webmOutputFormat
        )
        outputInfo = VideoProcessor.getOutputPaths(
            inputURL: options.inputURL,
            mp4: options.mp4OutputFormat,
            webm: options.webmOutputFormat
        )
        self.outputPaths = outputInfo.map { $0.path }
    }

    private func processOutput(
        _ output: (format: String, path: String),
        dispatchGroup: DispatchGroup,
        completion: @escaping (Bool) -> Void
    ) {
        let format = output.format
        let outputPath = output.path

        let ffmpegOptions = FFmpegArgumentsOptions(
            inputPath: url.path,
            removeAudio: videoSettings.removeAudio,
            selectedScale: videoSettings.selectedScale,
            compressionLevel: videoSettings.compressionLevel,
            format: format
        )

        let arguments = VideoProcessor.generateFFmpegArguments(options: ffmpegOptions)

        VideoProcessor.runFFmpegTask(
            arguments: arguments,
            outputPath: outputPath,
            onProcessCreated: { process in
                self.ffmpegTasks.append(process)
            },
            onTermination: { _ in
                dispatchGroup.leave()
            },
            completion: { success in
                completion(success)
            }
        )
    }

    private func handleCompletion(encounteredError: Bool) {
        if self.isCancelled {
            self.fileStatus.status = "Cancelled"
            self.cleanupOutputFiles()
        } else if encounteredError {
            self.fileStatus.status = "Failed"
            self.cleanupOutputFiles()
            print("Error processing file \(self.fileStatus.fileName)")
        } else {
            let outputSizes = self.outputPaths.map {
                self.viewModel.getFileSize(at: URL(fileURLWithPath: $0))
            }
            let totalOutputSize = outputSizes.reduce(0, +)
            let savings = self.fileStatus.originalSize - totalOutputSize
            self.fileStatus.newSize = totalOutputSize
            self.fileStatus.savings = savings
            self.fileStatus.status = "Completed"
        }
        // Remove the operation from the view model's operations dictionary
        self.viewModel.operations.removeValue(forKey: self.fileStatus.id)
        self.viewModel.checkForCompletion()
        self.finish()
    }

    override func cancel() {
        super.cancel()
        print("Cancel called for \(self.fileStatus.fileName)")

        for task in ffmpegTasks where task.isRunning {
            print("Terminating FFmpeg task for \(self.fileStatus.fileName)")
            task.terminate()
        }
    }

    private func cleanupOutputFiles() {
        print("Cleaning up output files for \(self.fileStatus.fileName)")
        for path in outputPaths {
            do {
                if FileManager.default.fileExists(atPath: path) {
                    try FileManager.default.removeItem(atPath: path)
                    print("Deleted incomplete file at path: \(path)")
                }
            } catch {
                print("Failed to delete file at path \(path): \(error)")
            }
        }
    }

    // Helper function to kill all ffmpeg processes for app quit
    func terminateAllFFmpegTasks() {
        for task in ffmpegTasks where task.isRunning {
            task.terminate()
        }
        cleanupOutputFiles()
    }
}
