import Foundation
import SwiftUI

class VideoProcessingOperation: AsyncOperation, @unchecked Sendable {
    private let fileStatus: FileStatus
    private let url: URL
    private let videoSettings: VideoSettings
    private let viewModel: ContentViewModel

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
        DispatchQueue.main.async {
            self.fileStatus.status = "Processing"
        }

        let inputSize = viewModel.getFileSize(at: url)
        DispatchQueue.main.async {
            self.fileStatus.originalSize = inputSize
        }

        let options = RunFFmpegOptions(
            inputURL: url,
            compressionLevel: videoSettings.compressionLevel,
            removeAudio: videoSettings.removeAudio,
            selectedScale: videoSettings.selectedScale,
            mp4OutputFormat: videoSettings.mp4OutputFormat,
            webmOutputFormat: videoSettings.webmOutputFormat
        )

        VideoProcessor.runFFmpeg(options: options) { success, message, outputPaths in
            DispatchQueue.main.async {
                if success {
                    let outputSizes = outputPaths.values.map {
                        self.viewModel.getFileSize(at: URL(fileURLWithPath: $0))
                    }
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
}
