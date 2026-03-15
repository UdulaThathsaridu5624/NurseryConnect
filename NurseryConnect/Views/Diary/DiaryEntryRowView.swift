// DiaryEntryRowView.swift — NurseryConnect
// Compact row for displaying a single diary entry in a list or feed.

import SwiftUI

struct DiaryEntryRowView: View {
    let entry: DiaryEntry

    private var entryColor: Color { Color.ncColor(forToken: entry.type.colorToken) }

    var body: some View {
        HStack(spacing: 12) {
            // Type icon
            Image(systemName: entry.type.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(entryColor)
                .frame(width: 34, height: 34)
                .background(entryColor.opacity(0.14), in: Circle())
                .accessibilityHidden(true)

            // Summary text
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.summaryText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(entry.timestamp, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !entry.notes.isEmpty {
                        Text("·")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                        Text(entry.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.type.displayName): \(entry.summaryText) at \(entry.timestamp.formatted(date: .omitted, time: .shortened))")
    }
}
