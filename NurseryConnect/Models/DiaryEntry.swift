// DiaryEntry.swift — NurseryConnect
// Polymorphic daily diary log entry (activity, sleep, meal, nappy, or wellbeing check).
// Enum raw values are stored as Strings in SwiftData for reliability.

import Foundation
import SwiftData

// MARK: - Supporting Enums

enum DiaryEntryType: String, CaseIterable {
    case activity = "activity"
    case sleep    = "sleep"
    case meal     = "meal"
    case nappy    = "nappy"
    case mood     = "mood"

    var displayName: String {
        switch self {
        case .activity: "Activity"
        case .sleep:    "Sleep / Nap"
        case .meal:     "Meal"
        case .nappy:    "Nappy / Toilet"
        case .mood:     "Wellbeing Check"
        }
    }

    var icon: String {
        switch self {
        case .activity: "figure.play"
        case .sleep:    "moon.stars.fill"
        case .meal:     "fork.knife"
        case .nappy:    "drop.fill"
        case .mood:     "heart.fill"
        }
    }

    var colorToken: String {
        switch self {
        case .activity: "blue"
        case .sleep:    "purple"
        case .meal:     "orange"
        case .nappy:    "cyan"
        case .mood:     "pink"
        }
    }
}

enum MoodRating: String, CaseIterable {
    case happy     = "happy"
    case content   = "content"
    case unsettled = "unsettled"
    case poorly    = "poorly"

    var emoji: String {
        switch self {
        case .happy:     "😄"
        case .content:   "🙂"
        case .unsettled: "😟"
        case .poorly:    "🤒"
        }
    }

    var displayName: String {
        switch self {
        case .happy:     "Happy"
        case .content:   "Content"
        case .unsettled: "Unsettled"
        case .poorly:    "Poorly"
        }
    }
}

enum FoodConsumed: String, CaseIterable {
    case all     = "all"
    case most    = "most"
    case half    = "half"
    case little  = "little"
    case none    = "none"
    case refused = "refused"

    var displayName: String { rawValue.capitalized }
}

enum NappyType: String, CaseIterable {
    case wet   = "wet"
    case dirty = "dirty"
    case both  = "both"
    case dry   = "dry"

    var displayName: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .wet:   "drop"
        case .dirty: "circle.fill"
        case .both:  "circle.lefthalf.filled"
        case .dry:   "checkmark.circle"
        }
    }
}

enum SleepPosition: String, CaseIterable {
    case back      = "back"
    case side      = "side"
    case monitored = "monitored"

    var displayName: String {
        switch self {
        case .back:      "On back (recommended)"
        case .side:      "On side"
        case .monitored: "Monitored position"
        }
    }
}

enum EYFSArea: String, CaseIterable {
    case communication      = "communication"
    case physicalDevelopment = "physicalDevelopment"
    case personalSocial     = "personalSocial"
    case literacy           = "literacy"
    case mathematics        = "mathematics"
    case understanding      = "understanding"
    case expressive         = "expressive"

    var displayName: String {
        switch self {
        case .communication:       "Communication & Language"
        case .physicalDevelopment: "Physical Development"
        case .personalSocial:      "Personal, Social & Emotional"
        case .literacy:            "Literacy"
        case .mathematics:         "Mathematics"
        case .understanding:       "Understanding the World"
        case .expressive:          "Expressive Arts & Design"
        }
    }
}

// MARK: - Model

@Model
final class DiaryEntry {
    var id: UUID
    var timestamp: Date
    /// DiaryEntryType.rawValue stored as String
    var typeRaw: String
    var notes: String

    // --- Activity fields ---
    var activityName: String?
    /// EYFSArea.rawValue
    var eyfsAreaRaw: String?
    var durationMinutes: Int?

    // --- Sleep fields ---
    var sleepStart: Date?
    var sleepEnd: Date?
    /// SleepPosition.rawValue
    var sleepPositionRaw: String?

    // --- Meal fields ---
    var mealType: String?     // "Breakfast" / "Morning Snack" / "Lunch" / "Afternoon Snack" / "Dinner"
    var foodOffered: String?
    /// FoodConsumed.rawValue
    var foodConsumedRaw: String?
    var fluidMl: Int?
    var fluidType: String?    // "Water" / "Milk" / "Juice" / "Other"

    // --- Nappy fields ---
    /// NappyType.rawValue
    var nappyTypeRaw: String?
    var nappyConcern: String?

    // --- Mood fields ---
    /// MoodRating.rawValue
    var moodRatingRaw: String?
    var checkTimeLabel: String?  // "Arrival" / "Midday" / "Departure"

    var child: Child?

    init(type: DiaryEntryType, notes: String = "", timestamp: Date = Date()) {
        self.id = UUID()
        self.timestamp = timestamp
        self.typeRaw = type.rawValue
        self.notes = notes
    }

    // MARK: - Type-safe accessors (computed, not stored)

    var type: DiaryEntryType {
        get { DiaryEntryType(rawValue: typeRaw) ?? .activity }
        set { typeRaw = newValue.rawValue }
    }

    var eyfsArea: EYFSArea? {
        get { eyfsAreaRaw.flatMap { EYFSArea(rawValue: $0) } }
        set { eyfsAreaRaw = newValue?.rawValue }
    }

    var sleepPosition: SleepPosition? {
        get { sleepPositionRaw.flatMap { SleepPosition(rawValue: $0) } }
        set { sleepPositionRaw = newValue?.rawValue }
    }

    var foodConsumed: FoodConsumed? {
        get { foodConsumedRaw.flatMap { FoodConsumed(rawValue: $0) } }
        set { foodConsumedRaw = newValue?.rawValue }
    }

    var nappyType: NappyType? {
        get { nappyTypeRaw.flatMap { NappyType(rawValue: $0) } }
        set { nappyTypeRaw = newValue?.rawValue }
    }

    var moodRating: MoodRating? {
        get { moodRatingRaw.flatMap { MoodRating(rawValue: $0) } }
        set { moodRatingRaw = newValue?.rawValue }
    }

    // MARK: - Derived helpers

    var sleepDurationText: String? {
        guard let start = sleepStart, let end = sleepEnd else { return nil }
        let diff = Int(end.timeIntervalSince(start))
        guard diff > 0 else { return nil }
        let h = diff / 3600
        let m = (diff % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m) min"
    }

    var summaryText: String {
        switch type {
        case .activity:
            return activityName ?? "Activity logged"
        case .sleep:
            if let dur = sleepDurationText { return "Slept for \(dur)" }
            return "Sleep / nap logged"
        case .meal:
            if let meal = mealType, let consumed = foodConsumed {
                return "\(meal) — ate \(consumed.displayName)"
            }
            return "Meal logged"
        case .nappy:
            return nappyType?.displayName.capitalized ?? "Nappy change"
        case .mood:
            if let mood = moodRating { return "\(mood.emoji) \(mood.displayName)" }
            return "Wellbeing check"
        }
    }
}
