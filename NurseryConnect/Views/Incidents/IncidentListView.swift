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
                List {
                    // Filter bar
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(label: "All", isSelected: filterStatus == nil) {
                                    withAnimation { filterStatus = nil }
                                }
                                ForEach(IncidentStatus.allCases, id: \.rawValue) { status in
                                    FilterChip(label: status.displayName, isSelected: filterStatus == status) {
                                        withAnimation { filterStatus = (filterStatus == status) ? nil : status }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.ncBackground)

                    if filteredReports.isEmpty {
                        Text("No incidents match the selected filter.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                            .listRowBackground(Color.ncBackground)
                    } else {
                        ForEach(filteredReports) { report in
                            NavigationLink(value: report) {
                                IncidentRowView(report: report)
                            }
                            .listRowBackground(Color.ncBackground)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color.ncBackground)
                .scrollContentBackground(.hidden)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: report.category.icon)
                    .foregroundStyle(report.category.isSevere ? .ncDanger : .ncWarning)
                Text(report.category.displayName)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                StatusBadgeView(status: report.status)
            }

            if let child = report.child {
                Label(child.fullName, systemImage: "person.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(report.descriptionText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Text(report.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                if report.requiresOfstedNotification {
                    Label("Ofsted notification required", systemImage: "exclamationmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.ncDanger)
                }
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
                .font(.caption.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule().fill(isSelected ? Color.ncDanger : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
