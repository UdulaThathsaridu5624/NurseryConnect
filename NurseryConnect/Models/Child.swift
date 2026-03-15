// Child.swift — NurseryConnect
// Data model representing a child assigned to this keyworker.

import Foundation
import SwiftData

@Model
final class Child {
    var id: UUID
    var firstName: String
    var lastName: String
    var preferredName: String
    var dateOfBirth: Date
    var roomName: String
    var keyworkerName: String
    /// Comma-separated list of allergens, e.g. "Nuts, Dairy"
    var allergies: String
    var dietaryNotes: String
    var photoName: String?

    @Relationship(deleteRule: .cascade)
    var diaryEntries: [DiaryEntry]

    @Relationship(deleteRule: .cascade)
    var incidentReports: [IncidentReport]

    init(
        firstName: String,
        lastName: String,
        preferredName: String = "",
        dateOfBirth: Date,
        roomName: String,
        keyworkerName: String = "Sarah Johnson",
        allergies: String = "",
        dietaryNotes: String = "",
        photoName: String? = nil
    ) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.preferredName = preferredName.isEmpty ? firstName : preferredName
        self.dateOfBirth = dateOfBirth
        self.roomName = roomName
        self.keyworkerName = keyworkerName
        self.allergies = allergies
        self.dietaryNotes = dietaryNotes
        self.photoName = photoName
        self.diaryEntries = []
        self.incidentReports = []
    }

    // MARK: - Computed helpers

    var fullName: String { "\(firstName) \(lastName)" }
    var displayName: String { preferredName.isEmpty ? firstName : preferredName }

    var initials: String {
        let f = firstName.first.map(String.init) ?? ""
        let l = lastName.first.map(String.init) ?? ""
        return "\(f)\(l)"
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
    }

    var hasAllergies: Bool {
        !allergies.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var allergyList: [String] {
        allergies
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var todaysDiaryEntries: [DiaryEntry] {
        let cal = Calendar.current
        return diaryEntries
            .filter { cal.isDateInToday($0.timestamp) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var lastMoodToday: MoodRating? {
        todaysDiaryEntries
            .first(where: { $0.type == .mood })?
            .moodRating
    }
}
