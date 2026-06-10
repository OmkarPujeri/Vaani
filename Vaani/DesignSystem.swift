import SwiftUI

extension Color {
    static let vaaniInk = Color(red: 0.14, green: 0.11, blue: 0.10)
    static let vaaniRose = Color(red: 0.60, green: 0.17, blue: 0.22)
    static let vaaniMarigold = Color(red: 0.82, green: 0.45, blue: 0.08)
    static let vaaniCream = Color(red: 0.99, green: 0.97, blue: 0.93)
    static let vaaniSage = Color(red: 0.82, green: 0.91, blue: 0.87)
}

enum VaaniSpacing {
    static let cornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 18
}

@MainActor
struct AppBackground: View {
    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.99, green: 0.96, blue: 0.90), location: 0.0),
                .init(color: Color(red: 0.96, green: 0.99, blue: 0.97), location: 0.52),
                .init(color: Color(red: 0.99, green: 0.94, blue: 0.96), location: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

@MainActor
struct HeaderBar: View {
    let phaseTitle: String

    var body: some View {
        HStack {
            Label("Vaani", systemImage: "waveform.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.vaaniInk)
                .accessibilityLabel("Vaani")

            Spacer()

            Text(phaseTitle)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.bottom, 14)
    }
}
