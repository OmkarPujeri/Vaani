import AVFoundation
import Foundation
import Observation
import Speech

@MainActor
@Observable
final class SpeechService {
    var transcript: String = ""
    var isListening: Bool = false
    var audioLevel: Float = 0.0
    var permissionDenied: Bool = false
    var error: Error?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func requestPermission() async -> Bool {
        let speechGranted = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        let microphoneGranted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }

        permissionDenied = !(speechGranted && microphoneGranted)
        return speechGranted && microphoneGranted
    }

    func startListening() async {
        do {
            stopAudioOnly()
            transcript = ""
            error = nil

            guard let recognizer, recognizer.isAvailable else {
                permissionDenied = true
                return
            }

            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
            request.shouldReportPartialResults = true
            recognitionRequest = request

            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.removeTap(onBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1_024, format: recordingFormat) { [weak self] buffer, _ in
                request.append(buffer)
                let level = Self.rmsLevel(from: buffer)
                Task { @MainActor in
                    self?.audioLevel = level
                }
            }

            audioEngine.prepare()
            try audioEngine.start()
            isListening = true

            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    if let result {
                        self?.transcript = result.bestTranscription.formattedString
                    }
                    if let error {
                        self?.error = error
                        _ = self?.stopListening()
                    }
                }
            }
        } catch {
            self.error = error
            permissionDenied = true
            stopAudioOnly()
        }
    }

    func stopListening() -> String {
        stopAudioOnly()
        isListening = false
        return transcript
    }

    func reset() {
        stopAudioOnly()
        transcript = ""
        audioLevel = 0
        error = nil
        permissionDenied = false
    }

    private func stopAudioOnly() {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
    }

    private nonisolated static func rmsLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else { return 0 }
        let frameLength = Int(buffer.frameLength)
        guard frameLength > 0 else { return 0 }

        var sum: Float = 0
        for index in 0..<frameLength {
            let sample = channelData[index]
            sum += sample * sample
        }

        let rms = sqrt(sum / Float(frameLength))
        return min(1.0, max(0.0, rms * 18.0))
    }
}
