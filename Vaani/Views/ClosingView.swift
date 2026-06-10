import SwiftUI

@MainActor
struct ClosingView: View {
    let card: MemoryCard
    let speakerName: String
    let onRestart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 10)

            VStack(alignment: .leading, spacing: 6) {
                Text("Today's memory from \(speakerName)")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.vaaniInk)

                Text("This is what lives on your home screen.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            WidgetPreviewMockup(card: card)

            MemoryCardView(card: card, isLarge: false)

            PrimaryButton(title: "Record another memory", systemImage: "mic.badge.plus", action: onRestart)

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 8)
    }
}
