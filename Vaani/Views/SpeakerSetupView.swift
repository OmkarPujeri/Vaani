import SwiftUI

@MainActor
struct SpeakerSetupView: View {
    @Binding var speakerName: String
    let onContinue: () -> Void

    private var initial: String {
        speakerName.trimmingCharacters(in: .whitespacesAndNewlines).first.map(String.init) ?? "?"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 12) {
                Text("Who will be speaking today?")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.vaaniInk)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Give them a name your family uses")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Text(initial.uppercased())
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(Color.vaaniRose, in: Circle())
                    .accessibilityHidden(true)

                TextField("e.g. Aaji, Dada, Nani, Thatha", text: $speakerName)
                    .font(.title3.weight(.semibold))
                    .textInputAutocapitalization(.words)
                    .padding(16)
                    .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
                    .overlay {
                        RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius)
                            .stroke(Color.vaaniRose.opacity(0.25))
                    }
                    .accessibilityLabel("Family name for speaker")
            }

            Spacer()

            PrimaryButton(title: "Continue", systemImage: "arrow.right.circle.fill", isDisabled: speakerName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2, action: onContinue)
        }
        .padding(.horizontal, 8)
    }
}
