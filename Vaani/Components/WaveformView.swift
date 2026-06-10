import SwiftUI

enum WaveformMode: Equatable {
    case `static`
    case live(audioLevel: Float)
}

@MainActor
struct WaveformView: View {
    let values: [Double]
    let tint: Color
    var mode: WaveformMode = .static

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var liveLevels: [Double] = Array(repeating: 0.18, count: 20)

    var body: some View {
        GeometryReader { proxy in
            let renderedValues = currentValues
            let barWidth = max(3.0, proxy.size.width / CGFloat(max(renderedValues.count, 1)) * 0.48)

            HStack(alignment: .center, spacing: max(2, barWidth * 0.55)) {
                ForEach(Array(renderedValues.enumerated()), id: \.offset) { _, value in
                    Capsule()
                        .fill(tint.opacity(0.76))
                        .frame(width: barWidth, height: max(8, proxy.size.height * value))
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.08), value: value)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .task(id: mode) {
            guard case .live = mode, !reduceMotion else { return }
            while !Task.isCancelled {
                updateLiveLevels()
                try? await Task.sleep(for: .milliseconds(80))
            }
        }
        .accessibilityHidden(true)
    }

    private var currentValues: [Double] {
        switch mode {
        case .static:
            values
        case .live:
            liveLevels
        }
    }

    private func updateLiveLevels() {
        let base: Double
        if case let .live(audioLevel) = mode {
            base = max(0.12, min(1.0, Double(audioLevel)))
        } else {
            base = 0.18
        }

        liveLevels = liveLevels.indices.map { index in
            let ripple = sin(Double(index) * 0.72 + Date().timeIntervalSinceReferenceDate * 8.0) * 0.16
            let random = Double.random(in: -0.12...0.22)
            return min(0.96, max(0.12, base + ripple + random))
        }
    }
}
