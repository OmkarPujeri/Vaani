import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
final class MemoryGenerator {
    struct CardData: Codable {
        let title: String
        let category: String
        let mood: String
        let people: [String]
        let summary: String
        let tags: [String]
    }

    func generate(from transcript: String, speaker: String) async -> MemoryCard {
        guard !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return SampleData.featuredCard
        }

        #if canImport(FoundationModels)
        guard #available(iOS 26, *) else { return makeFallback(transcript: transcript, speaker: speaker) }

        do {
            let session = LanguageModelSession()

            let prompt = """
            Analyze this spoken memory and return ONLY a JSON object,
            no preamble, no markdown, no explanation:

            "\(transcript)"

            Return exactly this JSON structure:
            {
              "title": "evocative title max 6 words",
              "category": "Story or Recipe or Song or Wisdom or Place",
              "mood": "warm or nostalgic or proud or joyful or reflective",
              "people": ["names mentioned"],
              "summary": "one sentence max 20 words",
              "tags": ["2 to 3 short topic keywords"]
            }
            """

            let response = try await session.respond(to: prompt)
            let clean = response.content
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard let data = clean.data(using: .utf8),
                  let cardData = try? JSONDecoder().decode(CardData.self, from: data)
            else {
                return makeFallback(transcript: transcript, speaker: speaker)
            }

            let category = MemoryCategory(rawValue: cardData.category) ?? .story

            return MemoryCard(
                title: cardData.title,
                speaker: speaker,
                category: category,
                date: .now,
                mood: cardData.mood,
                excerpt: cardData.summary,
                transcript: transcript,
                tags: Array(cardData.tags.prefix(3)),
                duration: 94,
                waveform: SampleData.featuredCard.waveform
            )
        } catch {
            return makeFallback(transcript: transcript, speaker: speaker)
        }
        #else
        return makeFallback(transcript: transcript, speaker: speaker)
        #endif
    }

    private func makeFallback(transcript: String, speaker: String) -> MemoryCard {
        let words = transcript.split(separator: " ").prefix(15).joined(separator: " ")
        let excerpt = words.isEmpty ? SampleData.featuredCard.excerpt : words + (transcript.split(separator: " ").count > 15 ? "..." : "")

        return MemoryCard(
            title: "A memory from \(speaker)",
            speaker: speaker,
            category: .story,
            date: .now,
            mood: "warm",
            excerpt: excerpt,
            transcript: transcript,
            tags: ["memory", "family"],
            duration: 94,
            waveform: SampleData.featuredCard.waveform
        )
    }
}
