import SwiftUI

@MainActor
struct PromptPickerView: View {
    let prompts: [ConversationPrompt]
    @Binding var selectedPrompt: ConversationPrompt
    let speakerName: String
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Pick one gentle question. Vaani does the interviewing, so the elder can simply speak.")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.vaaniInk)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 12) {
                ForEach(prompts) { prompt in
                    PromptRow(prompt: prompt, isSelected: prompt == selectedPrompt) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPrompt = prompt
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(title: "Listen to \(speakerName)", systemImage: "record.circle", action: onContinue)
                .accessibilityHint("Starts a memory recording")
        }
        .padding(.horizontal, 8)
    }
}

@MainActor
private struct PromptRow: View {
    let prompt: ConversationPrompt
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: prompt.category.symbol)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : prompt.category.tint)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? prompt.category.tint : prompt.category.tint.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(.headline)
                    Text(prompt.question)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? prompt.category.tint : .secondary)
                    .imageScale(.large)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(isSelected ? 0.92 : 0.68), in: RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: VaaniSpacing.cornerRadius)
                    .stroke(isSelected ? prompt.category.tint.opacity(0.70) : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(prompt.title). \(prompt.question)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }
}
