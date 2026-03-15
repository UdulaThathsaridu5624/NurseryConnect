// SectionCard.swift — NurseryConnect
// Reusable rounded card container with an optional header row.

import SwiftUI

struct SectionCard<Content: View>: View {
    var title: String?
    var icon: String?
    var iconColor: Color = .ncPrimary
    var content: () -> Content

    init(
        title: String? = nil,
        icon: String? = nil,
        iconColor: Color = .ncPrimary,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                HStack(spacing: 8) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(iconColor)
                    }
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                Divider()
                    .padding(.horizontal, 16)
            }

            content()
                .padding(16)
        }
        .ncCard()
    }
}
