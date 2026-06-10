import SwiftUI
#if os(iOS)
import UIKit
#endif

@MainActor
struct ListeningView: View {
    let prompt: ConversationPrompt
    let speakerName: String
    @Binding var speechService: SpeechService
    let onComplete: (String) -> Void

    @State private var hasStarted = false
    @State private var lastAnnouncedTranscript = ""

    private var visibleLines: [String] {
        if speechService.transcript.isEmpty {
            []
        } else {
            speechService.transcript
                .components(separatedBy: ". ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(prompt.question)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.vaaniInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Ask \(speakerName) to speak when ready")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                ListeningOrb(isActive: speechService.isListening)
                VStack(alignment: .leading, spacing: 4) {
                    Text(speechService.isListening ? "\(speakerName) is speaking" : statusText)
                        .font(.headline)
                    WaveformView(values: SampleData.featuredCard.waveform, tint: Color.vaaniRose, mode: .live(audioLevel: speechService.audioLevel))
                        .frame(height: 24)
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))

            if !hasStarted {
                Spacer()
                Button {
                    beginListening()
                } label: {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 88, height: 88)
                        .background(Color.vaaniRose, in: Circle())
                        .shadow(color: Color.vaaniRose.opacity(0.30), radius: 18, y: 8)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Start recording")
                .accessibilityAddTraits(.isButton)
                Spacer()
            }

            if speechService.permissionDenied {
                Text("Microphone and speech recognition access are needed to record a memory.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.vaaniRose)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Recording permission needed")
            } else if speechService.error != nil {
                Text("Recording stopped. You can try again or keep what was captured.")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(Color.vaaniRose)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(visibleLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.title3)
                            .lineSpacing(3)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.vertical, 2)
            }
            .accessibilityLabel("Live transcript")

            if !visibleLines.isEmpty {
                PrimaryButton(title: "Done", systemImage: "checkmark.circle.fill") {
                    let finalTranscript = speechService.stopListening()
                    onComplete(finalTranscript)
                }
            }

            if hasStarted && !speechService.isListening && visibleLines.isEmpty {
                PrimaryButton(title: "Try recording again", systemImage: "mic.circle.fill") {
                    speechService.reset()
                    hasStarted = false
                }
            }
        }
        .padding(.horizontal, 8)
        .onChange(of: speechService.transcript) { _, newValue in
            announceNewTranscript(from: newValue)
        }
    }

    private var statusText: String {
        if speechService.permissionDenied { "Permission needed" }
        else if speechService.error != nil { "Recording stopped" }
        else if visibleLines.isEmpty { "Ready to record" }
        else { "Memory captured" }
    }

    private func beginListening() {
        hasStarted = true
        Task { @MainActor in
            let granted = await speechService.requestPermission()
            guard granted else {
                return
            }
            await speechService.startListening()
        }
    }

    private func announceNewTranscript(from transcript: String) {
        guard transcript.count > lastAnnouncedTranscript.count else { return }
        let newText = String(transcript.dropFirst(lastAnnouncedTranscript.count)).trimmingCharacters(in: .whitespacesAndNewlines)
        lastAnnouncedTranscript = transcript
        guard !newText.isEmpty else { return }

        #if os(iOS)
        UIAccessibility.post(notification: .announcement, argument: newText)
        #endif
    }
}

@MainActor
private struct ListeningOrb: View {
    let isActive: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.vaaniRose.opacity(isActive && pulse ? 0.26 : 0.12))
                .frame(width: 64, height: 64)
                .scaleEffect(isActive && pulse ? 1.12 : 1.0)

            Image(systemName: isActive ? "waveform" : "checkmark")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.vaaniRose)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
        .accessibilityLabel(isActive ? "Recording in progress" : "Recording complete")
        .accessibilityAddTraits(.updatesFrequently)
    }
}
