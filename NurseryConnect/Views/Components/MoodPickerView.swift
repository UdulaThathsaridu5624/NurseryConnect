// MoodPickerView.swift — NurseryConnect
// Horizontal emoji button strip for selecting a child's mood rating.

import SwiftUI

struct MoodPickerView: View {
    @Binding var selection: MoodRating?

    var body: some View {
        HStack(spacing: 12) {
            ForEach(MoodRating.allCases, id: \.rawValue) { mood in
                MoodButton(mood: mood, isSelected: selection == mood) {
                    withAnimation(.spring(duration: 0.25)) {
                        selection = mood
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Mood selection")
    }
}

private struct MoodButton: View {
    let mood: MoodRating
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.system(size: isSelected ? 38 : 30))
                    .scaleEffect(isSelected ? 1.1 : 1)
                    .animation(.spring(duration: 0.25), value: isSelected)

                Text(mood.displayName)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.ncPrimary : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.ncPrimary.opacity(0.12) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(isSelected ? Color.ncPrimary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mood.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
