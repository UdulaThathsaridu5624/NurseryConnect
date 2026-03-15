// IncidentReport.swift — NurseryConnect
// RIDDOR-aligned digital incident report with status workflow and body map support.

import Foundation
import SwiftData

// MARK: - Supporting Enums

enum IncidentCategory: String, CaseIterable {
    case accidentMinor      = "accidentMinor"
    case accidentFirstAid   = "accidentFirstAid"
    case safeguardingConcern = "safeguardingConcern"
    case nearMiss           = "nearMiss"
    case allergicReaction   = "allergicReaction"
    case medicalIncident    = "medicalIncident"

    var displayName: String {
        switch self {
        case .accidentMinor:       "Accident (Minor)"
        case .accidentFirstAid:    "Accident (First Aid Required)"
        case .safeguardingConcern: "Safeguarding Concern"
        case .nearMiss:            "Near Miss"
        case .allergicReaction:    "Allergic Reaction"
        case .medicalIncident:     "Medical Incident"
        }
    }

    var icon: String {
        switch self {
        case .accidentMinor:       "bandage"
        case .accidentFirstAid:    "cross.case.fill"
        case .safeguardingConcern: "exclamationmark.shield.fill"
        case .nearMiss:            "exclamationmark.triangle.fill"
        case .allergicReaction:    "allergens"
        case .medicalIncident:     "heart.text.clipboard.fill"
        }
    }

    var isSevere: Bool {
        switch self {
        case .safeguardingConcern, .allergicReaction, .medicalIncident, .accidentFirstAid:
            true
        default:
            false
        }
    }
}

enum IncidentStatus: String, CaseIterable {
    case draft               = "draft"
    case submitted           = "submitted"
    case managerReviewed     = "managerReviewed"
    case parentNotified      = "parentNotified"
    case parentAcknowledged  = "parentAcknowledged"

    var displayName: String {
        switch self {
        case .draft:              "Draft"
        case .submitted:          "Submitted"
        case .managerReviewed:    "Manager Reviewed"
        case .parentNotified:     "Parent Notified"
        case .parentAcknowledged: "Parent Acknowledged"
        }
    }

    var icon: String {
        switch self {
        case .draft:              "pencil.circle"
        case .submitted:          "checkmark.circle"
        case .managerReviewed:    "person.badge.shield.checkmark.fill"
        case .parentNotified:     "bell.fill"
        case .parentAcknowledged: "checkmark.seal.fill"
        }
    }

    /// Status that follows this one in the workflow
    var nextStatus: IncidentStatus? {
        switch self {
        case .draft:              .submitted
        case .submitted:          .managerReviewed
        case .managerReviewed:    .parentNotified
        case .parentNotified:     .parentAcknowledged
        case .parentAcknowledged: nil
        }
    }

    /// Label for the button that advances to nextStatus
    var nextActionLabel: String? {
        switch self {
        case .draft:              "Submit Report"
        case .submitted:          "Mark as Manager Reviewed"
        case .managerReviewed:    "Mark as Parent Notified"
        case .parentNotified:     "Record Parent Acknowledgement"
        case .parentAcknowledged: nil
        }
    }

    /// Ordinal index for progress display (0-based)
    var stepIndex: Int {
        switch self {
        case .draft:              0
        case .submitted:          1
        case .managerReviewed:    2
        case .parentNotified:     3
        case .parentAcknowledged: 4
        }
    }

    static let totalSteps = 5
}

/// A tap-placed marker on the body map diagram, stored as JSON.
struct BodyMapDot: Codable, Identifiable {
    var id: UUID = UUID()
    /// Normalised x position (0 = left, 1 = right) within the body outline
    var x: Double
    /// Normalised y position (0 = top, 1 = bottom) within the body outline
    var y: Double
    /// "front" or "back"
    var side: String
}

// MARK: - Model

@Model
final class IncidentReport {
    var id: UUID
    var createdAt: Date
    /// IncidentCategory.rawValue
    var categoryRaw: String
    var location: String
    var descriptionText: String
    var immediateAction: String
    var witnesses: String
    /// JSON-encoded [BodyMapDot]
    var bodyMapData: Data?
    /// IncidentStatus.rawValue
    var statusRaw: String
    var parentAcknowledged: Bool
    var parentAcknowledgedAt: Date?
    var submittedAt: Date?

    var child: Child?

    init(
        category: IncidentCategory = .accidentMinor,
        location: String = "",
        descriptionText: String = "",
        immediateAction: String = "",
        witnesses: String = ""
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.categoryRaw = category.rawValue
        self.location = location
        self.descriptionText = descriptionText
        self.immediateAction = immediateAction
        self.witnesses = witnesses
        self.statusRaw = IncidentStatus.draft.rawValue
        self.parentAcknowledged = false
    }

    // MARK: - Type-safe accessors

    var category: IncidentCategory {
        get { IncidentCategory(rawValue: categoryRaw) ?? .accidentMinor }
        set { categoryRaw = newValue.rawValue }
    }

    var status: IncidentStatus {
        get { IncidentStatus(rawValue: statusRaw) ?? .draft }
        set { statusRaw = newValue.rawValue }
    }

    var bodyMapDots: [BodyMapDot] {
        get {
            guard let data = bodyMapData else { return [] }
            return (try? JSONDecoder().decode([BodyMapDot].self, from: data)) ?? []
        }
        set {
            bodyMapData = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Derived helpers

    var requiresOfstedNotification: Bool {
        category == .safeguardingConcern || category == .medicalIncident
    }

    var isComplete: Bool {
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty &&
        !immediateAction.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
