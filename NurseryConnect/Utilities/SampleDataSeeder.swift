// SampleDataSeeder.swift — NurseryConnect
// Inserts realistic demo children with diary entries and incident reports on first launch.
// Seeding is idempotent: guarded by a UserDefaults flag "ncDidSeedData".

import Foundation
import SwiftData

struct SampleDataSeeder {

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: "ncDidSeedData") else { return }
        insertSampleData(into: context)
        UserDefaults.standard.set(true, forKey: "ncDidSeedData")
    }

    // MARK: - Private helpers

    private static func date(daysAgo: Int, hour: Int = 9, minute: Int = 0) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.day! -= daysAgo
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }

    private static func dob(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    // MARK: - Main seed

    private static func insertSampleData(into context: ModelContext) {

        // ── Child 1: Lily Thompson ──────────────────────────────────────
        let lily = Child(
            firstName: "Lily",
            lastName: "Thompson",
            dateOfBirth: dob(year: 2022, month: 8, day: 14),
            roomName: "Butterflies",
            allergies: "",
            dietaryNotes: "Prefers fruit over vegetables. Loves pasta.",
            photoName: "Lily"
        )
        context.insert(lily)
        addDiaryEntries(for: lily, context: context)
        addIncidentReport(for: lily, context: context,
                          category: .accidentMinor,
                          location: "Outdoor play area",
                          description: "Lily tripped on the mat and grazed her left knee. She cried briefly and was comforted.",
                          action: "Area cleaned with antiseptic wipe. No further treatment required. Child settled quickly.",
                          witnesses: "Emma Davies (Room Leader)",
                          status: .parentAcknowledged,
                          daysAgo: 5)

        // ── Child 2: Noah Patel ─────────────────────────────────────────
        let noah = Child(
            firstName: "Noah",
            lastName: "Patel",
            dateOfBirth: dob(year: 2023, month: 11, day: 3),
            roomName: "Caterpillars",
            allergies: "Nuts",
            dietaryNotes: "Nut-free diet strictly required. Carries EpiPen. Full-fat dairy for age.",
            photoName: "Noah"
        )
        context.insert(noah)
        addDiaryEntries(for: noah, context: context)
        addIncidentReport(for: noah, context: context,
                          category: .allergicReaction,
                          location: "Dining room",
                          description: "Noah developed a mild rash on his forearm after lunch. Parent consulted; no EpiPen required. Rash subsided within 20 minutes.",
                          action: "Rash monitored. Parents called immediately. Antihistamine administered per parent instruction. Meal ingredients reviewed — no nut contamination found.",
                          witnesses: "Sarah Johnson (Keyworker), Lisa Chen (Cook)",
                          status: .managerReviewed,
                          daysAgo: 2)

        // ── Child 3: Amelia Clarke ──────────────────────────────────────
        let amelia = Child(
            firstName: "Amelia",
            lastName: "Clarke",
            preferredName: "Amy",
            dateOfBirth: dob(year: 2021, month: 4, day: 22),
            roomName: "Butterflies",
            allergies: "Gluten",
            dietaryNotes: "Coeliac disease — strict gluten-free diet. Separate utensils required.",
            photoName: "Amy"
        )
        context.insert(amelia)
        addDiaryEntries(for: amelia, context: context)

        // ── Child 4: Oliver Hassan ──────────────────────────────────────
        let oliver = Child(
            firstName: "Oliver",
            lastName: "Hassan",
            dateOfBirth: dob(year: 2022, month: 2, day: 17),
            roomName: "Caterpillars",
            allergies: "Dairy",
            dietaryNotes: "Dairy-free. Oat milk provided by parents. No cheese or yoghurt.",
            photoName: "Oliver"
        )
        context.insert(oliver)
        addDiaryEntries(for: oliver, context: context)
        addIncidentReport(for: oliver, context: context,
                          category: .nearMiss,
                          location: "Construction corner",
                          description: "A tower of blocks fell towards Oliver. No injury — he moved away in time. Area was not adequately cordoned off.",
                          action: "Rearranged construction area barriers. Risk assessment updated for block play area.",
                          witnesses: "Tom Wright (Keyworker Apprentice)",
                          status: .submitted,
                          daysAgo: 0)
    }

    // MARK: - Diary entries

    private static func addDiaryEntries(for child: Child, context: ModelContext) {
        // Arrival mood
        let arrivalMood = DiaryEntry(type: .mood, timestamp: date(daysAgo: 0, hour: 8, minute: 15))
        arrivalMood.moodRating = .happy
        arrivalMood.checkTimeLabel = "Arrival"
        arrivalMood.notes = "Arrived cheerful and eager to play."
        arrivalMood.child = child
        context.insert(arrivalMood)

        // Morning activity
        let activity = DiaryEntry(type: .activity, timestamp: date(daysAgo: 0, hour: 9, minute: 30))
        activity.activityName = "Sensory play with sand and water"
        activity.eyfsAreaRaw = EYFSArea.physicalDevelopment.rawValue
        activity.durationMinutes = 30
        activity.notes = "Explored textures confidently. Good concentration maintained throughout."
        activity.child = child
        context.insert(activity)

        // Breakfast meal
        let breakfast = DiaryEntry(type: .meal, timestamp: date(daysAgo: 0, hour: 8, minute: 45))
        breakfast.mealType = "Breakfast"
        breakfast.foodOffered = "Porridge with banana slices"
        breakfast.foodConsumedRaw = FoodConsumed.most.rawValue
        breakfast.fluidMl = 120
        breakfast.fluidType = "Water"
        breakfast.child = child
        context.insert(breakfast)

        // Nap
        let nap = DiaryEntry(type: .sleep, timestamp: date(daysAgo: 0, hour: 11, minute: 45))
        nap.sleepStart = date(daysAgo: 0, hour: 11, minute: 45)
        nap.sleepEnd   = date(daysAgo: 0, hour: 12, minute: 30)
        nap.sleepPositionRaw = SleepPosition.back.rawValue
        nap.notes = "Settled well. Slept soundly."
        nap.child = child
        context.insert(nap)

        // Nappy change
        let nappy = DiaryEntry(type: .nappy, timestamp: date(daysAgo: 0, hour: 10, minute: 0))
        nappy.nappyTypeRaw = NappyType.wet.rawValue
        nappy.notes = "No concerns noted."
        nappy.child = child
        context.insert(nappy)

        // Lunch
        let lunch = DiaryEntry(type: .meal, timestamp: date(daysAgo: 0, hour: 12, minute: 30))
        lunch.mealType = "Lunch"
        lunch.foodOffered = "Chicken with roast vegetables and mashed potato"
        lunch.foodConsumedRaw = FoodConsumed.all.rawValue
        lunch.fluidMl = 150
        lunch.fluidType = "Water"
        lunch.child = child
        context.insert(lunch)

        // Afternoon activity (from yesterday)
        let craftActivity = DiaryEntry(type: .activity, timestamp: date(daysAgo: 1, hour: 14, minute: 0))
        craftActivity.activityName = "Spring collage — cutting and sticking"
        craftActivity.eyfsAreaRaw = EYFSArea.expressive.rawValue
        craftActivity.durationMinutes = 25
        craftActivity.notes = "Showed great creativity and fine motor control."
        craftActivity.child = child
        context.insert(craftActivity)

        // Yesterday's mood at departure
        let departureMood = DiaryEntry(type: .mood, timestamp: date(daysAgo: 1, hour: 17, minute: 30))
        departureMood.moodRating = .content
        departureMood.checkTimeLabel = "Departure"
        departureMood.notes = "Left happily with parent. Had a positive day."
        departureMood.child = child
        context.insert(departureMood)
    }

    // MARK: - Incident report

    private static func addIncidentReport(
        for child: Child,
        context: ModelContext,
        category: IncidentCategory,
        location: String,
        description: String,
        action: String,
        witnesses: String,
        status: IncidentStatus,
        daysAgo: Int
    ) {
        let report = IncidentReport(
            category: category,
            location: location,
            descriptionText: description,
            immediateAction: action,
            witnesses: witnesses
        )
        report.createdAt = date(daysAgo: daysAgo, hour: 14, minute: 30)
        report.statusRaw = status.rawValue
        report.parentAcknowledged = (status == .parentAcknowledged)
        if status == .parentAcknowledged {
            report.parentAcknowledgedAt = date(daysAgo: daysAgo, hour: 16, minute: 0)
        }
        if status != .draft {
            report.submittedAt = date(daysAgo: daysAgo, hour: 15, minute: 0)
        }
        report.child = child
        context.insert(report)
    }
}
