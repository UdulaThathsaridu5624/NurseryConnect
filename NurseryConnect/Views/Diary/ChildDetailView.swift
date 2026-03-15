// ChildDetailView.swift — NurseryConnect
// Shows a child's today-at-a-glance summary, quick-log action buttons,
// allergy/dietary alerts, and navigation to the full diary feed.

import SwiftUI
import SwiftData

struct ChildDetailView: View {
    let child: Child

    @State private var showNewEntry = false
    @State private var selectedType: DiaryEntryType = .activity
    @State private var showNewIncident = false

    private var todayEntries: [DiaryEntry] { child.todaysDiaryEntries }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                profileHeader
                if child.hasAllergies { allergyAlert }
                quickLogSection
                todaySummarySection
                incidentButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color.ncBackground)
        .navigationTitle(child.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showNewEntry) {
            NewDiaryEntryView(child: child, preselectedType: selectedType)
        }
        .sheet(isPresented: $showNewIncident) {
            NewIncidentReportView(preselectedChild: child)
        }
        .navigationDestination(for: String.self) { dest in
            if dest == "diary" {
                DiaryFeedView(child: child)
            }
        }
    }

    // MARK: - Profile header

    private var profileHeader: some View {
        SectionCard {
            HStack(spacing: 16) {
                ChildAvatarView(child: child, size: 66)

                VStack(alignment: .leading, spacing: 4) {
                    Text(child.fullName)
                        .font(.title3.weight(.bold))
                    HStack(spacing: 8) {
                        Label(child.roomName, systemImage: "door.left.hand.open")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("·")
                            .foregroundStyle(.secondary)
                        Label("\(child.age) years", systemImage: "birthday.cake")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if let mood = child.lastMoodToday {
                        Label("\(mood.emoji) \(mood.displayName)", systemImage: "")
                            .font(.subheadline)
                            .foregroundStyle(.ncPrimary)
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Allergy alert banner

    private var allergyAlert: some View {
        HStack(spacing: 12) {
            Image(systemName: "allergens")
                .font(.title3)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Allergy Alert")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(child.allergyList.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
                if !child.dietaryNotes.isEmpty {
                    Text(child.dietaryNotes)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(.ncDanger, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Allergy alert: \(child.allergyList.joined(separator: ", ")). \(child.dietaryNotes)")
    }

    // MARK: - Quick log buttons

    private var quickLogSection: some View {
        SectionCard(title: "Quick Log", icon: "plus.circle.fill", iconColor: .ncPrimary) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(DiaryEntryType.allCases, id: \.rawValue) { type in
                    QuickLogButton(type: type) {
                        selectedType = type
                        showNewEntry = true
                    }
                }
            }
        }
    }

    // MARK: - Today's diary summary

    private var todaySummarySection: some View {
        SectionCard(title: "Today's Diary", icon: "clock.fill", iconColor: .ncAccent) {
            VStack(alignment: .leading, spacing: 0) {
                if todayEntries.isEmpty {
                    Text("No entries yet today. Tap Quick Log above to add the first one.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                } else {
                    ForEach(Array(todayEntries.prefix(4).enumerated()), id: \.element.id) { idx, entry in
                        DiaryEntryRowView(entry: entry)
                        if idx < min(todayEntries.count, 4) - 1 {
                            Divider().padding(.vertical, 4)
                        }
                    }
                    if todayEntries.count > 4 {
                        Text("+ \(todayEntries.count - 4) more entries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 6)
                    }
                }

                NavigationLink(value: "diary") {
                    Label("View Full Diary", systemImage: "chevron.right")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.ncPrimary)
                        .labelStyle(IconOnlyAfterLabel())
                }
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Incident button

    private var incidentButton: some View {
        Button {
            showNewIncident = true
        } label: {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("Report an Incident")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(.ncDanger, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .accessibilityLabel("Report an incident for \(child.displayName)")
    }
}

// MARK: - Quick log button cell

private struct QuickLogButton: View {
    let type: DiaryEntryType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundStyle(Color.ncColor(forToken: type.colorToken))
                    .frame(width: 36, height: 36)
                    .background(Color.ncColor(forToken: type.colorToken).opacity(0.12), in: Circle())

                Text(type.displayName.components(separatedBy: " ").first ?? type.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log \(type.displayName)")
    }
}

// MARK: - Custom label style helper

private struct IconOnlyAfterLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}
