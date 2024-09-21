import Foundation

struct RunFFmpegOptions {
    var inputURL: URL
    var compressionLevel: String
    var removeAudio: Bool
    var selectedScale: String
    var mp4OutputFormat: Bool
    var webmOutputFormat: Bool
}

struct FFmpegArgumentsOptions {
    var inputPath: String
    var removeAudio: Bool
    var selectedScale: String
    var compressionLevel: String
    var format: String
}

class VideoProcessor {
    static func runFFmpeg(
        options: RunFFmpegOptions,
        completion: @escaping (Bool, String, [String: String]) -> Void
    ) {
        let ffmpegPath = Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/ffmpeg").path

        if !FileManager.default.fileExists(atPath: ffmpegPath) {
            print("FFmpeg binary not found.")
            completion(false, "FFmpeg binary not found", [:])
            return
        }

        let outputPaths = getOutputPaths(
            inputURL: options.inputURL,
            mp4: options.mp4OutputFormat,
            webm: options.webmOutputFormat
        )

        if outputPaths.isEmpty {
            completion(false, "No output formats selected.", [:])
            return
        }

        let dispatchGroup = DispatchGroup()
        var encounteredError = false
        var processedOutputs: [String: String] = [:]

        for output in outputPaths {
            dispatchGroup.enter()
            let format = output.format
            let outputPath = output.path

            let options = FFmpegArgumentsOptions(
                inputPath: options.inputURL.path,
                removeAudio: options.removeAudio,
                selectedScale: options.selectedScale,
                compressionLevel: options.compressionLevel,
                format: format
            )

            let arguments = generateFFmpegArguments(options: options)

            runFFmpegTask(ffmpegPath: ffmpegPath, arguments: arguments, outputPath: outputPath) { success in
                if success {
                    processedOutputs[format] = outputPath
                } else {
                    encounteredError = true
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if encounteredError {
                completion(false, "An error occurred during video processing.", processedOutputs)
            } else {
                completion(true, "Video optimized successfully!", processedOutputs)
            }
        }
    }

    static func getOutputPaths(inputURL: URL, mp4: Bool, webm: Bool) -> [(format: String, path: String)] {
        let inputDirectory = inputURL.deletingLastPathComponent()
        let inputBaseName = inputURL.deletingPathExtension().lastPathComponent
        let baseNameWithoutOptimized = inputBaseName.replacingOccurrences(of: "_optimized", with: "")
        let outputBaseName = baseNameWithoutOptimized + "_optimized_\(UUID().uuidString.prefix(8))"
        var outputPaths = [(format: String, path: String)]()

        if mp4 {
            let outputPath = uniqueOutputPath(
                directory: inputDirectory,
                baseName: outputBaseName,
                extension: "mp4"
            )
            outputPaths.append((format: "mp4", path: outputPath))
        }

        if webm {
            let outputPath = uniqueOutputPath(
                directory: inputDirectory,
                baseName: outputBaseName,
                extension: "webm"
            )
            outputPaths.append((format: "webm", path: outputPath))
        }

        return outputPaths
    }

    static func uniqueOutputPath(directory: URL, baseName: String, extension ext: String) -> String {
        var outputPath = directory.appendingPathComponent("\(baseName).\(ext)").path
        var fileCounter = 2
        while FileManager.default.fileExists(atPath: outputPath) {
            outputPath = directory.appendingPathComponent("\(baseName)-\(fileCounter).\(ext)").path
            fileCounter += 1
        }
        return outputPath
    }

    static func generateFFmpegArguments(options: FFmpegArgumentsOptions) -> [String] {
        var arguments = ["-y", "-i", options.inputPath, "-loglevel", "error"]

        if options.removeAudio {
            arguments += ["-an"]
        }

        if let scaleValue = scaleOptions[options.selectedScale], !scaleValue.isEmpty {
            arguments += ["-vf", "scale=\(scaleValue):-2"]
        }

        let crfValue = determineCRFValue(for: options.format, compressionLevel: options.compressionLevel)

        switch options.format {
            case "mp4":
                arguments += ["-vcodec", "libx264", "-crf", crfValue]
            case "webm":
                arguments += [
                    "-vcodec", "libvpx-vp9",
                    "-crf", crfValue,
                    "-b:v", "0",
                    "-deadline", "good",
                    "-cpu-used", "5"]
            default:
                break
        }

        return arguments
    }

    static func determineCRFValue(for format: String, compressionLevel: String) -> String {
        switch (format, compressionLevel) {
            case ("mp4", "High"): return "32"
            case ("mp4", "Medium"): return "28"
            case ("mp4", "Low"): return "23"
            case ("webm", "High"): return "53"
            case ("webm", "Medium"): return "47"
            case ("webm", "Low"): return "40"
            default: return (format == "mp4") ? "28" : "47"
        }
    }

    static func runFFmpegTask(
        ffmpegPath: String,
        arguments: [String],
        outputPath: String,
        completion: @escaping (Bool) -> Void
    ) {
        var updatedArguments = arguments
        updatedArguments.append(outputPath)

        let task = Process()
        task.executableURL = URL(fileURLWithPath: ffmpegPath)
        task.arguments = updatedArguments

        let pipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = pipe
        task.standardError = errorPipe

        task.terminationHandler = { process in
            if process.terminationStatus != 0 {
                print("FFmpeg encountered an error for output \(outputPath)")
                completion(false)
            } else {
                print("FFmpeg completed successfully for output \(outputPath)")
                completion(true)
            }
        }

        do {
            try task.run()
            print("FFmpeg task started successfully for output \(outputPath)")
        } catch {
            print("Failed to run FFmpeg for output \(outputPath): \(error)")
            completion(false)
        }
    }
}
