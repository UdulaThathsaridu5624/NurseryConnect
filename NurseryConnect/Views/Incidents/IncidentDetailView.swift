// IncidentDetailView.swift — NurseryConnect
// Full incident report detail with status timeline and workflow action buttons.

import SwiftUI
import SwiftData

struct IncidentDetailView: View {
    let report: IncidentReport

    @Environment(\.modelContext) private var context
    @State private var showAdvanceConfirmation = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                categoryHeader
                statusTimeline
                if !report.bodyMapDots.isEmpty { bodyMapSection }
                detailsSection
                if !report.witnesses.isEmpty { witnessesSection }
                if report.requiresOfstedNotification { ofstedBanner }
                actionButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.ncBackground)
        .navigationTitle("Incident Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Report", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog(
            report.status.nextActionLabel ?? "Action",
            isPresented: $showAdvanceConfirmation,
            titleVisibility: .visible
        ) {
            Button("Confirm", role: .none) { advanceStatus() }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let next = report.status.nextStatus {
                Text("This will mark the report as '\(next.displayName)'.")
            }
        }
        .confirmationDialog("Delete this incident report?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(report)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Category header

    private var categoryHeader: some View {
        HStack(spacing: 14) {
            Image(systemName: report.category.icon)
                .font(.title2)
                .foregroundStyle(report.category.isSevere ? .ncDanger : .ncWarning)
                .frame(width: 52, height: 52)
                .background(
                    (report.category.isSevere ? Color.ncDanger : Color.ncWarning).opacity(0.14),
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(report.category.displayName)
                    .font(.headline.weight(.bold))
                if let child = report.child {
                    Label(child.fullName, systemImage: "person.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text(report.createdAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
        }
        .padding(16)
        .ncCard()
    }

    // MARK: - Status timeline

    private var statusTimeline: some View {
        SectionCard(title: "Status", icon: "arrow.triangle.2.circlepath", iconColor: .ncPrimary) {
            VStack(spacing: 0) {
                ForEach(IncidentStatus.allCases, id: \.rawValue) { step in
                    let reached = report.status.stepIndex >= step.stepIndex
                    let isCurrent = report.status == step

                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(reached ? Color.ncPrimary : Color(.systemGray5))
                                .frame(width: 28, height: 28)
                            Image(systemName: reached ? "checkmark" : step.icon)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(reached ? .white : .secondary)
                        }

                        Text(step.displayName)
                            .font(isCurrent ? .subheadline.weight(.semibold) : .subheadline)
                            .foregroundStyle(reached ? .primary : .secondary)

                        Spacer()

                        if isCurrent {
                            Text("Current")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.ncPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.ncPrimary.opacity(0.12), in: Capsule())
                        }
                    }

                    if step != .parentAcknowledged {
                        Rectangle()
                            .fill(reached && report.status.stepIndex > step.stepIndex ? Color.ncPrimary : Color(.systemGray5))
                            .frame(width: 2, height: 18)
                            .padding(.leading, 13)
                    }
                }
            }
        }
    }

    // MARK: - Body map section

    private var bodyMapSection: some View {
        SectionCard(title: "Body Map", icon: "figure.stand", iconColor: .ncPrimary) {
            ReadOnlyBodyMapView(dots: report.bodyMapDots)
        }
    }

    // MARK: - Details section

    private var detailsSection: some View {
        SectionCard(title: "Incident Details", icon: "doc.text.fill", iconColor: .ncAccent) {
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(label: "Location", value: report.location)
                Divider()
                DetailRow(label: "What happened", value: report.descriptionText)
                Divider()
                DetailRow(label: "Immediate action", value: report.immediateAction)
            }
        }
    }

    // MARK: - Witnesses section

    private var witnessesSection: some View {
        SectionCard(title: "Witnesses", icon: "person.2.fill", iconColor: .ncSecondary) {
            Text(report.witnesses)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Ofsted banner

    private var ofstedBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.title3)
                .foregroundStyle(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text("Ofsted Notification Required")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text("This incident category requires notification to Ofsted. The Setting Manager will initiate the formal process.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(14)
        .background(.ncDanger, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Action button

    @ViewBuilder private var actionButton: some View {
        if let label = report.status.nextActionLabel {
            Button {
                showAdvanceConfirmation = true
            } label: {
                HStack {
                    Image(systemName: report.status.nextStatus?.icon ?? "checkmark.circle.fill")
                    Text(label)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
                .padding(16)
                .background(.ncPrimary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        } else {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("All workflow steps complete.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(16)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Status advance

    private func advanceStatus() {
        guard let next = report.status.nextStatus else { return }
        withAnimation(.spring(duration: 0.35)) {
            report.statusRaw = next.rawValue
            if next == .parentAcknowledged {
                report.parentAcknowledged = true
                report.parentAcknowledgedAt = Date()
            }
        }
    }
}

// MARK: - Helper views

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

// ReadOnlyBodyMapView and BodySilhouette are defined in BodyMapView.swift
