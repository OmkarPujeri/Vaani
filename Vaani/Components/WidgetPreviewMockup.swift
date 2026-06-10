import SwiftUI

@MainActor
struct WidgetPreviewMockup: View {
    let card: MemoryCard

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [Color.black.opacity(0.58), Color.vaaniRose.opacity(0.34), Color.vaaniSage.opacity(0.34)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 220, height: 220)

                widget
            }

            Text("Daily widget · automatically updates")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var widget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: "waveform")
                    .font(.system(size: 12, weight: .bold))
                Text("Vaani")
                    .font(.caption.weight(.semibold))
                Spacer()
            }
            .foregroundStyle(Color.vaaniRose)

            Spacer(minLength: 0)

            Text(card.title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.vaaniInk)
                .lineLimit(2)

            Text(card.speaker)
                .font(.caption)
                .foregroundStyle(.secondary)

            WaveformView(values: card.waveform, tint: card.category.tint)
                .frame(height: 16)

            HStack(alignment: .bottom) {
                HStack(spacing: 4) {
                    ForEach(card.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 8, weight: .semibold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .background(card.category.tint.opacity(0.12), in: Capsule())
                            .foregroundStyle(card.category.tint)
                    }
                }
                Spacer()
                Text(card.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .frame(width: 168, height: 168)
        .background(Color.vaaniCream, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Daily Vaani widget preview for \(card.title)")
    }
}
