import Foundation
import SwiftUI

enum MemoryCategory: String, CaseIterable, Identifiable, Sendable {
    case story = "Story"
    case recipe = "Recipe"
    case song = "Song"
    case wisdom = "Wisdom"
    case place = "Place"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .story: "book.pages"
        case .recipe: "fork.knife"
        case .song: "music.note"
        case .wisdom: "sparkles"
        case .place: "mappin.and.ellipse"
        }
    }

    var tint: Color {
        switch self {
        case .story: Color(red: 0.60, green: 0.17, blue: 0.22)
        case .recipe: Color(red: 0.08, green: 0.41, blue: 0.34)
        case .song: Color(red: 0.25, green: 0.29, blue: 0.67)
        case .wisdom: Color(red: 0.72, green: 0.39, blue: 0.10)
        case .place: Color(red: 0.12, green: 0.43, blue: 0.64)
        }
    }
}

struct MemoryCard: Identifiable, Equatable, Sendable {
    let id = UUID()
    let title: String
    let speaker: String
    let category: MemoryCategory
    let date: Date
    let mood: String
    let excerpt: String
    let transcript: String
    let tags: [String]
    let duration: TimeInterval
    let waveform: [Double]

    var durationText: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}

struct ConversationPrompt: Identifiable, Equatable, Sendable {
    let id = UUID()
    let title: String
    let question: String
    let category: MemoryCategory
}

enum SpeechState: Equatable {
    case idle
    case requestingPermission
    case listening
    case unavailable
    case finished
}

enum SampleData {
    static let prompts: [ConversationPrompt] = [
        ConversationPrompt(
            title: "Childhood Home",
            question: "Tell me about the place you grew up in.",
            category: .place
        ),
        ConversationPrompt(
            title: "Festival Memory",
            question: "What did Diwali feel like when you were young?",
            category: .story
        ),
        ConversationPrompt(
            title: "Family Recipe",
            question: "Which recipe should our family never forget?",
            category: .recipe
        )
    ]

    static let liveTranscript = [
        "In our old house in Nashik,",
        "there was a mango tree right in the middle of the courtyard.",
        "Every summer, all the children would sit below it after lunch.",
        "Your great-grandmother would bring steel plates of sliced mango,",
        "and she would tell us stories until the evening light became golden.",
        "I remember the sound of everyone laughing more than anything else."
    ]

    static let featuredCard = MemoryCard(
        title: "The Mango Tree",
        speaker: "Aaji",
        category: .place,
        date: Date(timeIntervalSinceReferenceDate: 802_915_200),
        mood: "warm",
        excerpt: "A summer courtyard memory filled with mangoes, stories, and evening light.",
        transcript: liveTranscript.joined(separator: " "),
        tags: ["Nashik", "childhood", "family home"],
        duration: 94,
        waveform: [0.22, 0.42, 0.31, 0.62, 0.55, 0.80, 0.44, 0.36, 0.70, 0.92, 0.50, 0.35, 0.64, 0.77, 0.40, 0.26, 0.48, 0.66, 0.51, 0.30]
    )

    static let archiveCards: [MemoryCard] = [
        featuredCard,
        MemoryCard(
            title: "The Diwali Lamp",
            speaker: "Aaji",
            category: .story,
            date: Date(timeIntervalSinceReferenceDate: 799_372_800),
            mood: "joyful",
            excerpt: "A childhood Diwali when every window held a tiny handmade lamp.",
            transcript: "We made the diyas ourselves and lined them across every window before sunset.",
            tags: ["Diwali", "light", "tradition"],
            duration: 72,
            waveform: [0.30, 0.58, 0.44, 0.76, 0.36, 0.52, 0.82, 0.61, 0.48, 0.25]
        ),
        MemoryCard(
            title: "Jaggery Poha",
            speaker: "Aaji",
            category: .recipe,
            date: Date(timeIntervalSinceReferenceDate: 792_028_800),
            mood: "nostalgic",
            excerpt: "A simple breakfast recipe remembered by taste, rhythm, and care.",
            transcript: "First wash the poha softly. Then add jaggery, coconut, and patience.",
            tags: ["recipe", "poha", "kitchen"],
            duration: 58,
            waveform: [0.18, 0.36, 0.50, 0.41, 0.63, 0.44, 0.28, 0.54, 0.70, 0.32]
        )
    ]
}
