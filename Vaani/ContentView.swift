import SwiftUI

@MainActor
struct ContentView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var hSizeClass

    @State private var phase: AppPhase = .intro
    @State private var speakerName = ""
    @State private var selectedPrompt = SampleData.prompts[0]
    @State private var generatedCard: MemoryCard?
    @State private var archiveCards = SampleData.archiveCards
    @State private var speechService = SpeechService()
    private let memoryGenerator = MemoryGenerator()

    private enum AppPhase: Equatable {
        case intro
        case speakerSetup
        case prompts
        case listening
        case generated
        case archive
        case closing
    }

    var body: some View {
        ZStack {
            AppBackground()
            if hSizeClass == .regular {
                HStack(spacing: 24) {
                    phaseContent
                        .frame(width: 380)
                    ArchiveView(cards: archiveCards, showsContinueButton: phase == .archive) {
                        move(to: .closing)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    HeaderBar(phaseTitle: phaseTitle)
                    phaseContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
            }
        }
        .foregroundStyle(.primary)
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch phase {
        case .intro:
            IntroView { move(to: .speakerSetup) }
        case .speakerSetup:
            SpeakerSetupView(speakerName: $speakerName) { move(to: .prompts) }
        case .prompts:
            PromptPickerView(prompts: SampleData.prompts, selectedPrompt: $selectedPrompt, speakerName: displaySpeaker) {
                startListening()
            }
        case .listening:
            ListeningView(prompt: selectedPrompt, speakerName: displaySpeaker, speechService: $speechService) { transcript in
                finishListening(with: transcript)
            }
        case .generated:
            GeneratedCardView(card: generatedCard ?? fallbackCard) { addGeneratedCardToArchive() }
        case .archive:
            ArchiveView(cards: archiveCards) { move(to: .closing) }
        case .closing:
            ClosingView(card: archiveCards[0], speakerName: displaySpeaker) { resetFlow() }
        }
    }

    private var displaySpeaker: String { speakerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Aaji" : speakerName }

    private var fallbackCard: MemoryCard {
        MemoryCard(title: SampleData.featuredCard.title, speaker: displaySpeaker, category: SampleData.featuredCard.category, date: .now, mood: SampleData.featuredCard.mood, excerpt: SampleData.featuredCard.excerpt, transcript: SampleData.featuredCard.transcript, tags: SampleData.featuredCard.tags, duration: SampleData.featuredCard.duration, waveform: SampleData.featuredCard.waveform)
    }

    private var phaseTitle: String {
        switch phase {
        case .intro: "Vaani"
        case .speakerSetup: "Who's speaking"
        case .prompts: "Choose a question"
        case .listening: "Listening"
        case .generated: "Memory saved"
        case .archive: "Family archive"
        case .closing: "Today"
        }
    }

    private func move(to newPhase: AppPhase) {
        withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86)) {
            phase = newPhase
        }
    }

    private func startListening() {
        generatedCard = nil
        speechService.reset()
        move(to: .listening)
    }

    private func finishListening(with transcript: String) {
        Task { @MainActor in
            generatedCard = await memoryGenerator.generate(from: transcript, speaker: displaySpeaker)
            move(to: .generated)
        }
    }

    private func addGeneratedCardToArchive() {
        let card = generatedCard ?? fallbackCard
        archiveCards = [card] + SampleData.archiveCards.filter { $0.id != card.id }
        move(to: .archive)
    }

    private func resetFlow() {
        generatedCard = nil
        archiveCards = SampleData.archiveCards
        speechService.reset()
        move(to: .intro)
    }
}
