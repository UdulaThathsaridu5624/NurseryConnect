// NewIncidentReportView.swift — NurseryConnect
// RIDDOR-aligned incident report form with category selection, body map, and workflow submission.

import SwiftUI
import SwiftData

struct NewIncidentReportView: View {
    var preselectedChild: Child?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Child.firstName) private var children: [Child]

    @State private var selectedChild: Child?
    @State private var category: IncidentCategory = .accidentMinor
    @State private var location: String = ""
    @State private var descriptionText: String = ""
    @State private var immediateAction: String = ""
    @State private var witnesses: String = ""
    @State private var bodyMapDots: [BodyMapDot] = []
    @State private var saveAsDraft = true

    @State private var showValidationAlert = false

    private var isValid: Bool {
        selectedChild != nil &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !immediateAction.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var validationMessage: String {
        if selectedChild == nil { return "Please select the child involved." }
        if location.trimmingCharacters(in: .whitespaces).isEmpty { return "Please enter where the incident occurred." }
        if descriptionText.trimmingCharacters(in: .whitespaces).isEmpty { return "Please describe what happened." }
        if immediateAction.trimmingCharacters(in: .whitespaces).isEmpty { return "Please describe the immediate action taken." }
        return ""
    }

    init(preselectedChild: Child?) {
        self.preselectedChild = preselectedChild
        _selectedChild = State(initialValue: preselectedChild)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Child selection
                Section("Child Involved") {
                    Picker("Child", selection: $selectedChild) {
                        Text("Select a child").tag(Optional<Child>.none)
                        ForEach(children) { child in
                            Text(child.fullName).tag(Optional(child))
                        }
                    }
                    if let child = selectedChild, child.hasAllergies {
                        Label("Allergy alert: \(child.allergies)", systemImage: "allergens")
                            .font(.caption)
                            .foregroundStyle(.ncDanger)
                    }
                }

                // Incident category
                Section("Incident Category") {
                    Picker("Category", selection: $category) {
                        ForEach(IncidentCategory.allCases, id: \.rawValue) { cat in
                            Label(cat.displayName, systemImage: cat.icon).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)

                    if category.isSevere {
                        Label("This category may require Ofsted notification. The Setting Manager will be alerted.", systemImage: "exclamationmark.shield.fill")
                            .font(.caption)
                            .foregroundStyle(.ncDanger)
                    }
                }

                // Incident details (auto-filled time is read-only per EYFS requirement)
                Section("Incident Details") {
                    HStack {
                        Text("Date & Time")
                        Spacer()
                        Text(Date(), style: .time) + Text(", ") + Text(Date(), style: .date)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    TextField("Location (e.g. Outdoor play area)", text: $location)

                    TextField("What happened? (describe clearly and factually)", text: $descriptionText, axis: .vertical)
                        .lineLimit(4...8)

                    TextField("Immediate action taken", text: $immediateAction, axis: .vertical)
                        .lineLimit(3...6)
                }

                // Witnesses
                Section("Witnesses") {
                    TextField("Names and roles of any witnesses", text: $witnesses, axis: .vertical)
                        .lineLimit(2...4)
                }

                // Body map
                Section {
                    BodyMapView(dots: $bodyMapDots)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                } header: {
                    Text("Body Map (optional)")
                } footer: {
                    Text("Mark the location of any injury on the body outline above.")
                }

                // EYFS compliance note
                Section {
                    Label("Under EYFS statutory requirements, parents must be informed of all accidents on the same day.", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color(.systemGray6))
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") { save(asDraft: false) }
                        .fontWeight(.semibold)
                        .foregroundStyle(isValid ? Color.ncDanger : .secondary)
                        .disabled(!isValid)
                }
            }
            .alert("Missing Information", isPresented: $showValidationAlert) {
                Button("OK") {}
            } message: {
                Text(validationMessage)
            }
            .safeAreaInset(edge: .bottom) {
                if isValid {
                    Button("Save as Draft") { save(asDraft: true) }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
            }
        }
    }

    // MARK: - Save

    private func save(asDraft: Bool) {
        guard isValid else { showValidationAlert = true; return }

        let report = IncidentReport(
            category: category,
            location: location,
            descriptionText: descriptionText,
            immediateAction: immediateAction,
            witnesses: witnesses
        )
        report.child = selectedChild
        report.bodyMapDots = bodyMapDots
        report.statusRaw = asDraft ? IncidentStatus.draft.rawValue : IncidentStatus.submitted.rawValue
        if !asDraft {
            report.submittedAt = Date()
        }

        withAnimation {
            context.insert(report)
        }
        dismiss()
    }
}
