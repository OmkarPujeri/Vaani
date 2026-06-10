import SwiftUI

struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: DemoPhase = .intro
    @State private var selectedPrompt = DemoData.prompts[0]
    @State private var transcriptLines: [String] = []
    @State private var generatedCard: MemoryCard?
    @State private var archiveCards = DemoData.archiveCards
    @State private var isPlayingMemory = false

    private enum DemoPhase {
        case intro
        case prompts
        case listening
        case generated
        case archive
        case closing
    }

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                HeaderBar(phaseTitle: phaseTitle)

                Group {
                    switch phase {
                    case .intro:
                        IntroView {
                            move(to: .prompts)
                        }
                    case .prompts:
                        PromptPickerView(
                            prompts: DemoData.prompts,
                            selectedPrompt: $selectedPrompt
                        ) {
                            startListeningDemo()
                        }
                    case .listening:
                        ListeningView(
                            prompt: selectedPrompt,
                            transcriptLines: transcriptLines,
                            isPlaying: isPlayingMemory
                        )
                    case .generated:
                        GeneratedCardView(card: generatedCard ?? DemoData.featuredCard) {
                            move(to: .archive)
                        }
                    case .archive:
                        ArchiveView(cards: archiveCards) {
                            move(to: .closing)
                        }
                    case .closing:
                        ClosingView(card: archiveCards[0]) {
                            resetDemo()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
        }
        .foregroundStyle(.primary)
    }

    private var phaseTitle: String {
        switch phase {
        case .intro: "Vaani"
        case .prompts: "Choose a question"
        case .listening: "Listening"
        case .generated: "Memory saved"
        case .archive: "Family archive"
        case .closing: "Today"
        }
    }

    private func move(to newPhase: DemoPhase) {
        withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86)) {
            phase = newPhase
        }
    }

    private func startListeningDemo() {
        transcriptLines = []
        generatedCard = nil
        isPlayingMemory = true
        move(to: .listening)

        Task { @MainActor in
            for (index, line) in DemoData.liveTranscript.enumerated() {
                try? await Task.sleep(for: .milliseconds(reduceMotion ? 80 : 760))
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) {
                    transcriptLines.append(line)
                }

                if index == DemoData.liveTranscript.indices.last {
                    try? await Task.sleep(for: .milliseconds(reduceMotion ? 120 : 650))
                    generatedCard = DemoData.featuredCard
                    isPlayingMemory = false
                    move(to: .generated)
                }
            }
        }
    }

    private func resetDemo() {
        transcriptLines = []
        generatedCard = nil
        archiveCards = DemoData.archiveCards
        isPlayingMemory = false
        move(to: .intro)
    }
}

private struct HeaderBar: View {
    let phaseTitle: String

    var body: some View {
        HStack {
            Label("Vaani", systemImage: "waveform.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.vaaniInk)
                .accessibilityLabel("Vaani")

            Spacer()

            Text(phaseTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 14)
    }
}

private struct IntroView: View {
    let onBegin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            Spacer(minLength: 12)

            VStack(alignment: .leading, spacing: 16) {
                Text("Some stories disappear if no one asks.")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.vaaniInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Vaani helps a family turn a grandparent's voice into private memory cards, so recipes, places, songs, and wisdom stay close.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }

            FeatureStrip()

            PrimaryButton(title: "Start a memory", systemImage: "mic.circle.fill", action: onBegin)
                .accessibilityHint("Begins the three minute Vaani demo")

            Spacer(minLength: 10)
        }
        .padding(.horizontal, 8)
    }
}

private struct FeatureStrip: View {
    private let features = [
        ("Offline", "lock.shield"),
        ("Voice-first", "waveform"),
        ("Family archive", "square.stack.3d.up")
    ]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(features, id: \.0) { feature in
                VStack(spacing: 8) {
                    Image(systemName: feature.1)
                        .font(.title2)
                        .foregroundStyle(Color.vaaniMarigold)
                    Text(feature.0)
                        .font(.caption.weight(.semibold))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 76)
                .padding(10)
                .background(Color.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.08))
                }
            }
        }
    }
}

private struct PromptPickerView: View {
    let prompts: [ConversationPrompt]
    @Binding var selectedPrompt: ConversationPrompt
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Pick one gentle question. Vaani does the interviewing, so the elder can simply speak.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.vaaniInk)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(prompts) { prompt in
                    PromptRow(
                        prompt: prompt,
                        isSelected: prompt == selectedPrompt
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPrompt = prompt
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(title: "Listen to Aaji", systemImage: "record.circle", action: onContinue)
                .accessibilityHint("Starts a simulated offline memory recording")
        }
        .padding(.horizontal, 8)
    }
}

private struct PromptRow: View {
    let prompt: ConversationPrompt
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: prompt.category.symbol)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : prompt.category.tint)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? prompt.category.tint : prompt.category.tint.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(.headline)
                    Text(prompt.question)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? prompt.category.tint : .secondary)
                    .imageScale(.large)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(isSelected ? 0.92 : 0.68), in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? prompt.category.tint.opacity(0.70) : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(prompt.title). \(prompt.question)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}

private struct ListeningView: View {
    let prompt: ConversationPrompt
    let transcriptLines: [String]
    let isPlaying: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(prompt.question)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.vaaniInk)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 14) {
                ListeningOrb(isActive: isPlaying)
                VStack(alignment: .leading, spacing: 4) {
                    Text(isPlaying ? "Aaji is speaking" : "Memory captured")
                        .font(.headline)
                    Text("No network. No upload. Just a voice becoming a keepsake.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 8))

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(transcriptLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.title3)
                            .lineSpacing(3)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8))
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.vertical, 2)
            }
            .accessibilityLabel("Live transcript")
        }
        .padding(.horizontal, 8)
    }
}

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
        .accessibilityHidden(true)
    }
}

private struct GeneratedCardView: View {
    let card: MemoryCard
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 4)

            Text("Vaani found the shape of the memory.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.vaaniInk)
                .frame(maxWidth: .infinity, alignment: .leading)

            MemoryCardView(card: card, isLarge: true)
                .transition(.scale(scale: 0.94).combined(with: .opacity))

            PrimaryButton(title: "Add to archive", systemImage: "tray.and.arrow.down.fill", action: onContinue)

            Spacer(minLength: 6)
        }
        .padding(.horizontal, 8)
    }
}

private struct ArchiveView: View {
    let cards: [MemoryCard]
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("A private timeline grows every time someone asks.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.vaaniInk)
                .fixedSize(horizontal: false, vertical: true)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(cards) { card in
                        ArchiveRow(card: card)
                    }
                }
            }

            PrimaryButton(title: "Show today's memory", systemImage: "sun.max.fill", action: onContinue)
        }
        .padding(.horizontal, 8)
    }
}

private struct ArchiveRow: View {
    let card: MemoryCard

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Circle()
                    .fill(card.category.tint)
                    .frame(width: 14, height: 14)
                Rectangle()
                    .fill(card.category.tint.opacity(0.26))
                    .frame(width: 2, height: 54)
            }

            MemoryCardView(card: card, isLarge: false)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.title), \(card.category.rawValue), spoken by \(card.speaker)")
    }
}

private struct ClosingView: View {
    let card: MemoryCard
    let onRestart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 10)

            Text("Today's memory from \(card.speaker)")
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.vaaniInk)

            MemoryCardView(card: card, isLarge: true)

            Text("For the challenge, this prototype uses local demo memories so it is fully offline and small. The full Vaani vision can later add Indian-language on-device transcription.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryButton(title: "Replay demo", systemImage: "arrow.counterclockwise", action: onRestart)

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 8)
    }
}

private struct MemoryCardView: View {
    let card: MemoryCard
    let isLarge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isLarge ? 14 : 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: card.category.symbol)
                    .font(isLarge ? .title2 : .headline)
                    .foregroundStyle(.white)
                    .frame(width: isLarge ? 46 : 38, height: isLarge ? 46 : 38)
                    .background(card.category.tint, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(card.category.rawValue.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(card.category.tint)

                    Text(card.title)
                        .font(isLarge ? .title2.weight(.bold) : .headline.weight(.bold))
                        .foregroundStyle(Color.vaaniInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(card.speaker) · \(card.durationText) · \(card.mood)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            WaveformView(values: card.waveform, tint: card.category.tint)
                .frame(height: isLarge ? 48 : 30)

            Text(card.excerpt)
                .font(isLarge ? .body : .subheadline)
                .foregroundStyle(Color.vaaniInk.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                ForEach(card.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(card.category.tint.opacity(0.12), in: Capsule())
                        .foregroundStyle(card.category.tint)
                }
            }
        }
        .padding(isLarge ? 18 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.08))
        }
        .shadow(color: .black.opacity(isLarge ? 0.12 : 0.06), radius: isLarge ? 18 : 8, y: isLarge ? 10 : 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.category.rawValue) memory titled \(card.title), spoken by \(card.speaker). \(card.excerpt)")
    }
}

private struct WaveformView: View {
    let values: [Double]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let barWidth = max(3.0, proxy.size.width / CGFloat(max(values.count, 1)) * 0.48)

            HStack(alignment: .center, spacing: max(2, barWidth * 0.55)) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, value in
                    Capsule()
                        .fill(tint.opacity(0.76))
                        .frame(width: barWidth, height: max(8, proxy.size.height * value))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .accessibilityHidden(true)
    }
}

private struct PrimaryButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(Color.vaaniInk, in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

private struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.95, blue: 0.88),
                Color(red: 0.93, green: 0.98, blue: 0.96),
                Color(red: 0.98, green: 0.92, blue: 0.93)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private extension Color {
    static let vaaniInk = Color(red: 0.14, green: 0.11, blue: 0.10)
    static let vaaniRose = Color(red: 0.60, green: 0.17, blue: 0.22)
    static let vaaniMarigold = Color(red: 0.82, green: 0.45, blue: 0.08)
}
