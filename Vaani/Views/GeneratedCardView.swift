import SwiftUI

@MainActor
struct GeneratedCardView: View {
    let card: MemoryCard
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showMessage = false
    @State private var showContainer = false
    @State private var showIcon = false
    @State private var showTitle = false
    @State private var showMeta = false
    @State private var showWaveform = false
    @State private var showExcerpt = false
    @State private var showTags = false
    @State private var showButton = false

    var body: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 4)

            Text("Vaani found the shape of this memory.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.vaaniInk)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(showMessage ? 1 : 0)
                .offset(y: showMessage ? 0 : 8)

            assembledCard
                .opacity(showContainer ? 1 : 0)
                .scaleEffect(showContainer ? 1 : 0.92)

            if showButton {
                PrimaryButton(title: "Add to archive", systemImage: "tray.and.arrow.down.fill", action: onContinue)
                    .transition(.opacity)
            }

            Spacer(minLength: 6)
        }
        .padding(.horizontal, 8)
        .onAppear { runAnimation() }
    }

    private var assembledCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: card.category.symbol)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(card.category.tint, in: Circle())
                    .opacity(showIcon ? 1 : 0)
                    .offset(y: showIcon ? 0 : -18)

                VStack(alignment: .leading, spacing: 4) {
                    Text(card.category.rawValue.uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(card.category.tint)
                        .opacity(showMeta ? 1 : 0)
                        .offset(y: showMeta ? 0 : 12)

                    Text(card.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.vaaniInk)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 12)

                    Text("\(card.speaker) · \(card.durationText) · \(card.mood)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .opacity(showMeta ? 1 : 0)
                        .offset(y: showMeta ? 0 : 12)
                }

                Spacer()
            }

            WaveformView(values: card.waveform, tint: card.category.tint)
                .frame(height: 48)
                .scaleEffect(y: showWaveform ? 1 : 0.05, anchor: .center)
                .opacity(showWaveform ? 1 : 0)

            Text(card.excerpt)
                .font(.body)
                .foregroundStyle(Color.vaaniInk.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
                .opacity(showExcerpt ? 1 : 0)
                .offset(y: showExcerpt ? 0 : 12)

            HStack {
                ForEach(Array(card.tags.enumerated()), id: \.element) { index, tag in
                    Text(tag)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(card.category.tint.opacity(0.12), in: Capsule())
                        .foregroundStyle(card.category.tint)
                        .opacity(showTags ? 1 : 0)
                        .offset(x: showTags ? 0 : CGFloat(-10 - index * 4), y: showTags ? 0 : 12)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06), value: showTags)
                }
            }
        }
        .padding(VaaniSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
        .overlay {
            RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius)
                .stroke(Color.black.opacity(0.08))
        }
        .shadow(color: .black.opacity(0.12), radius: 18, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.category.rawValue) memory titled \(card.title), spoken by \(card.speaker). \(card.excerpt)")
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showIcon)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showTitle)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showMeta)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showWaveform)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showExcerpt)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showTags)
    }

    private func runAnimation() {
        Task { @MainActor in
            if reduceMotion {
                showMessage = true
                showContainer = true
                showIcon = true
                showTitle = true
                showMeta = true
                showWaveform = true
                showExcerpt = true
                showTags = true
                showButton = true
                return
            }

            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.easeOut(duration: 0.25)) { showMessage = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { showContainer = true }
            try? await Task.sleep(for: .milliseconds(200))
            showIcon = true
            try? await Task.sleep(for: .milliseconds(280))
            showTitle = true
            try? await Task.sleep(for: .milliseconds(240))
            showMeta = true
            try? await Task.sleep(for: .milliseconds(180))
            showWaveform = true
            try? await Task.sleep(for: .milliseconds(200))
            showExcerpt = true
            try? await Task.sleep(for: .milliseconds(200))
            showTags = true
            try? await Task.sleep(for: .milliseconds(300))
            withAnimation(.easeOut(duration: 0.25)) { showButton = true }
        }
    }
}
