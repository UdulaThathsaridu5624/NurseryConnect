// IncidentListView.swift — NurseryConnect
// Shows all incident reports across assigned children, ordered by date.

import SwiftUI
import SwiftData

struct IncidentListView: View {
    @Query(sort: \IncidentReport.createdAt, order: .reverse) private var reports: [IncidentReport]
    @Query(sort: \Child.firstName) private var children: [Child]

    @State private var showNewIncident = false
    @State private var filterStatus: IncidentStatus? = nil

    private var filteredReports: [IncidentReport] {
        guard let filter = filterStatus else { return reports }
        return reports.filter { $0.status == filter }
    }

    var body: some View {
        Group {
            if reports.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    // Filter bar — sits above the scroll list with proper margin
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "All", isSelected: filterStatus == nil) {
                                withAnimation(.spring(duration: 0.25)) { filterStatus = nil }
                            }
                            ForEach(IncidentStatus.allCases, id: \.rawValue) { status in
                                FilterChip(label: status.displayName, isSelected: filterStatus == status) {
                                    withAnimation(.spring(duration: 0.25)) {
                                        filterStatus = (filterStatus == status) ? nil : status
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    Divider()

                    // Incident rows
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            if filteredReports.isEmpty {
                                Text("No incidents match the selected filter.")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 40)
                            } else {
                                ForEach(filteredReports) { report in
                                    NavigationLink(value: report) {
                                        IncidentRowView(report: report)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .background(Color.ncBackground)
            }
        }
        .navigationTitle("Incidents")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: IncidentReport.self) { report in
            IncidentDetailView(report: report)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showNewIncident = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.ncDanger)
                }
                .accessibilityLabel("Report new incident")
            }
        }
        .sheet(isPresented: $showNewIncident) {
            NewIncidentReportView(preselectedChild: nil)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(.ncPrimary.opacity(0.35))
            Text("No Incidents Recorded")
                .font(.title3.weight(.semibold))
            Text("All incident reports will appear here. Tap + to log a new one.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ncBackground)
    }
}

// MARK: - Incident row

struct IncidentRowView: View {
    let report: IncidentReport

    private var iconColor: Color { report.category.isSevere ? .ncDanger : .ncWarning }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title row: icon circle + category name
            HStack(spacing: 10) {
                Image(systemName: report.category.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 34, height: 34)
                    .background(iconColor.opacity(0.12), in: Circle())

                Text(report.category.displayName)
                    .font(.subheadline.weight(.semibold))

                Spacer()
            }

            // Child name
            if let child = report.child {
                Label(child.fullName, systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Description preview
            Text(report.descriptionText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            // Footer: date + status badge on same row
            HStack(alignment: .center) {
                Text(report.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                if report.requiresOfstedNotification {
                    Label("Ofsted", systemImage: "exclamationmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.ncDanger)
                }
                Spacer()
                StatusBadgeView(status: report.status)
            }
        }
        .padding(14)
        .ncCard()
    }
}

// MARK: - Filter chip

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Color.white : Color.ncPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isSelected ? Color.ncDanger : Color.ncPrimary.opacity(0.10))
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
