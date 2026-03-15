// StatusBadgeView.swift — NurseryConnect
// Pill-shaped badge for incident status display.

import SwiftUI

struct StatusBadgeView: View {
    let status: IncidentStatus

    private var badgeColor: Color {
        switch status {
        case .draft:              return .gray
        case .submitted:          return .blue
        case .managerReviewed:    return .ncPrimary
        case .parentNotified:     return .ncWarning
        case .parentAcknowledged: return .green
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2.weight(.semibold))
            Text(status.displayName)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(badgeColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor.opacity(0.14), in: Capsule())
        .accessibilityLabel("Status: \(status.displayName)")
    }
}

// MARK: - Category badge

struct CategoryBadgeView: View {
    let category: IncidentCategory

    private var badgeColor: Color {
        category.isSevere ? .ncDanger : .ncWarning
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
                .font(.caption2.weight(.semibold))
            Text(category.displayName)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(badgeColor, in: Capsule())
        .accessibilityLabel("Category: \(category.displayName)")
    }
}
