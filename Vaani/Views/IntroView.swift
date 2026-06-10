import SwiftUI

@MainActor
struct IntroView: View {
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
                .accessibilityHint("Opens memory recording")

            Spacer(minLength: 10)
        }
        .padding(.horizontal, 8)
    }
}

@MainActor
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
                .background(Color.white.opacity(0.74), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius)
                        .stroke(Color.black.opacity(0.08))
                }
            }
        }
    }
}
