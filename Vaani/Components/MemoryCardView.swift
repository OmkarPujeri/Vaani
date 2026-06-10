import SwiftUI

@MainActor
struct MemoryCardView: View {
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
        .padding(isLarge ? VaaniSpacing.cardPadding : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius)
                .stroke(Color.black.opacity(0.08))
        }
        .shadow(color: .black.opacity(isLarge ? 0.12 : 0.06), radius: isLarge ? 18 : 8, y: isLarge ? 10 : 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.category.rawValue) memory titled \(card.title), spoken by \(card.speaker). \(card.excerpt)")
    }
}
