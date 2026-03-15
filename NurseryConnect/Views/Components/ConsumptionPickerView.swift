// ConsumptionPickerView.swift — NurseryConnect
// Custom segmented picker for the EYFS food-consumption scale.

import SwiftUI

struct ConsumptionPickerView: View {
    @Binding var selection: FoodConsumed?
    var label: String = "Amount eaten"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Two rows: all / most / half on top; little / none / refused on bottom
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    ForEach([FoodConsumed.all, .most, .half], id: \.rawValue) { option in
                        ConsumptionButton(option: option, isSelected: selection == option) {
                            withAnimation(.spring(duration: 0.2)) { selection = option }
                        }
                    }
                }
                HStack(spacing: 6) {
                    ForEach([FoodConsumed.little, .none, .refused], id: \.rawValue) { option in
                        ConsumptionButton(option: option, isSelected: selection == option) {
                            withAnimation(.spring(duration: 0.2)) { selection = option }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(label)
    }
}

private struct ConsumptionButton: View {
    let option: FoodConsumed
    let isSelected: Bool
    let action: () -> Void

    private var color: Color {
        switch option {
        case .all:     return .green
        case .most:    return .mint
        case .half:    return .ncAccent
        case .little:  return .ncWarning
        case .none:    return .ncDanger
        case .refused: return .red
        }
    }

    var body: some View {
        Button(action: action) {
            Text(option.displayName)
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : (isSelected ? color : .primary))
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isSelected ? color : Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
