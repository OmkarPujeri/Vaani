import SwiftUI

@MainActor
struct ArchiveView: View {
    let cards: [MemoryCard]
    var showsContinueButton = true
    let onContinue: () -> Void

    @State private var selectedFilter: MemoryCategory?

    private var filteredCards: [MemoryCard] {
        guard let selectedFilter else { return cards }
        return cards.filter { $0.category == selectedFilter }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("A private timeline grows every time someone asks.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.vaaniInk)
                .fixedSize(horizontal: false, vertical: true)

            filterChips

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(Array(filteredCards.enumerated()), id: \.element.id) { index, card in
                        ArchiveRow(card: card, index: index)
                    }
                }
            }

            if showsContinueButton {
                PrimaryButton(title: "Show today's memory", systemImage: "sun.max.fill", action: onContinue)
            }
        }
        .padding(.horizontal, 8)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "All", symbol: "square.grid.2x2", tint: Color.vaaniInk, isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }

                ForEach(MemoryCategory.allCases) { category in
                    filterChip(title: category.rawValue, symbol: category.symbol, tint: category.tint, isSelected: selectedFilter == category) {
                        selectedFilter = category
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(title: String, symbol: String, tint: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? tint : tint.opacity(0.10), in: Capsule())
                .foregroundStyle(isSelected ? .white : tint)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) memories filter")
    }
}

@MainActor
private struct ArchiveRow: View {
    let card: MemoryCard
    let index: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            VStack {
                Image(systemName: card.category.symbol)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(card.category.tint)
                    .frame(width: 18, height: 18)
                Rectangle()
                    .fill(card.category.tint.opacity(0.26))
                    .frame(width: 2, height: 54)
            }

            MemoryCardView(card: card, isLarge: false)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : 28)
        .onAppear {
            Task { @MainActor in
                guard !reduceMotion else {
                    isVisible = true
                    return
                }
                try? await Task.sleep(for: .milliseconds(Int(Double(index) * 80)))
                withAnimation(.spring(response: 0.45, dampingFraction: 0.84)) {
                    isVisible = true
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.category.rawValue) memory: \(card.title), \(card.durationText), spoken by \(card.speaker)")
    }
}
