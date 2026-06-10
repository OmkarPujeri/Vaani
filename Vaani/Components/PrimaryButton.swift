import SwiftUI

@MainActor
struct PrimaryButton: View {
    let title: String
    let systemImage: String
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(isDisabled ? Color.vaaniInk.opacity(0.34) : Color.vaaniInk, in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityHint(accessibilityHint)
    }

    private var accessibilityHint: String {
        switch title {
        case "Start a memory": "Opens memory recording"
        case "Add to archive": "Saves this card to the family archive"
        default: ""
        }
    }
}
