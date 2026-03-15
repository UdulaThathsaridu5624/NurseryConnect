// NewDiaryEntryView.swift — NurseryConnect
// Type-switched form for creating a new diary entry (activity, sleep, meal, nappy, or mood).

import SwiftUI
import SwiftData

struct NewDiaryEntryView: View {
    let child: Child
    var preselectedType: DiaryEntryType = .activity

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    // Common
    @State private var selectedType: DiaryEntryType
    @State private var notes: String = ""
    @State private var timestamp: Date = Date()

    // Activity
    @State private var activityName: String = ""
    @State private var eyfsArea: EYFSArea? = nil
    @State private var durationMinutes: Int = 15

    // Sleep
    @State private var sleepStart: Date = Date().addingTimeInterval(-3600)
    @State private var sleepEnd: Date = Date()
    @State private var sleepPosition: SleepPosition = .back

    // Meal
    @State private var mealType: String = "Lunch"
    @State private var foodOffered: String = ""
    @State private var foodConsumed: FoodConsumed? = nil
    @State private var fluidMl: Int = 120
    @State private var fluidType: String = "Water"

    // Nappy
    @State private var nappyType: NappyType = .wet
    @State private var nappyConcern: String = ""

    // Mood
    @State private var moodRating: MoodRating? = nil
    @State private var checkTimeLabel: String = "Midday"

    @State private var showValidationAlert = false

    private static let mealTypes = ["Breakfast", "Morning Snack", "Lunch", "Afternoon Snack", "Dinner"]
    private static let fluidTypes = ["Water", "Milk", "Diluted Juice", "Other"]
    private static let checkTimes = ["Arrival", "Midday", "Departure"]

    init(child: Child, preselectedType: DiaryEntryType = .activity) {
        self.child = child
        self.preselectedType = preselectedType
        _selectedType = State(initialValue: preselectedType)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Type picker
                Section {
                    Picker("Entry type", selection: $selectedType) {
                        ForEach(DiaryEntryType.allCases, id: \.rawValue) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)

                    DatePicker("Time", selection: $timestamp, displayedComponents: [.hourAndMinute])
                }

                // Type-specific fields
                switch selectedType {
                case .activity: activitySection
                case .sleep:    sleepSection
                case .meal:     mealSection
                case .nappy:    nappySection
                case .mood:     moodSection
                }

                // Notes (always visible)
                Section("Notes") {
                    TextField("Additional observations…", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log \(selectedType.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(isValid ? Color.ncPrimary : .secondary)
                        .disabled(!isValid)
                }
            }
            .alert("Missing Information", isPresented: $showValidationAlert) {
                Button("OK") {}
            } message: {
                Text(validationMessage)
            }
        }
    }

    // MARK: - Activity section

    @ViewBuilder private var activitySection: some View {
        Section("Activity Details") {
            TextField("Activity name (e.g. Sensory play)", text: $activityName)

            Picker("EYFS Area", selection: $eyfsArea) {
                Text("None selected").tag(Optional<EYFSArea>.none)
                ForEach(EYFSArea.allCases, id: \.rawValue) { area in
                    Text(area.displayName).tag(Optional(area))
                }
            }

            Stepper("Duration: \(durationMinutes) min", value: $durationMinutes, in: 5...180, step: 5)
        }
    }

    // MARK: - Sleep section

    @ViewBuilder private var sleepSection: some View {
        Section("Sleep Details") {
            DatePicker("Fell asleep", selection: $sleepStart, displayedComponents: [.hourAndMinute])
            DatePicker("Woke up", selection: $sleepEnd, displayedComponents: [.hourAndMinute])

            if sleepEnd > sleepStart {
                let mins = Int(sleepEnd.timeIntervalSince(sleepStart)) / 60
                Text("Duration: \(mins / 60)h \(mins % 60)m")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            Picker("Sleep position", selection: $sleepPosition) {
                ForEach(SleepPosition.allCases, id: \.rawValue) { pos in
                    Text(pos.displayName).tag(pos)
                }
            }
        }
    }

    // MARK: - Meal section

    @ViewBuilder private var mealSection: some View {
        Section("Meal Details") {
            Picker("Meal", selection: $mealType) {
                ForEach(Self.mealTypes, id: \.self) { Text($0) }
            }

            TextField("Food offered (e.g. Pasta bolognese)", text: $foodOffered)

            ConsumptionPickerView(selection: $foodConsumed)
        }

        Section("Fluid Intake") {
            HStack {
                Text("Amount (ml)")
                Spacer()
                Stepper("\(fluidMl) ml", value: $fluidMl, in: 0...500, step: 30)
                    .fixedSize()
            }

            Picker("Drink type", selection: $fluidType) {
                ForEach(Self.fluidTypes, id: \.self) { Text($0) }
            }
        }
    }

    // MARK: - Nappy section

    @ViewBuilder private var nappySection: some View {
        Section("Nappy Change") {
            Picker("Type", selection: $nappyType) {
                ForEach(NappyType.allCases, id: \.rawValue) { type in
                    Label(type.displayName, systemImage: type.icon).tag(type)
                }
            }
            .pickerStyle(.segmented)

            TextField("Any concerns? (optional)", text: $nappyConcern)
        }
    }

    // MARK: - Mood / wellbeing section

    @ViewBuilder private var moodSection: some View {
        Section("Wellbeing Check") {
            Picker("Check time", selection: $checkTimeLabel) {
                ForEach(Self.checkTimes, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
        }

        Section("Mood") {
            MoodPickerView(selection: $moodRating)
        }
    }

    // MARK: - Validation

    private var isValid: Bool {
        switch selectedType {
        case .activity: return !activityName.trimmingCharacters(in: .whitespaces).isEmpty
        case .sleep:    return sleepEnd > sleepStart
        case .meal:     return !foodOffered.trimmingCharacters(in: .whitespaces).isEmpty && foodConsumed != nil
        case .nappy:    return true
        case .mood:     return moodRating != nil
        }
    }

    private var validationMessage: String {
        switch selectedType {
        case .activity: return "Please enter an activity name."
        case .sleep:    return "Wake-up time must be after sleep start time."
        case .meal:     return "Please enter the food offered and select how much was eaten."
        case .nappy:    return ""
        case .mood:     return "Please select a mood."
        }
    }

    // MARK: - Save

    private func save() {
        guard isValid else { showValidationAlert = true; return }

        let entry = DiaryEntry(type: selectedType, notes: notes, timestamp: timestamp)
        entry.child = child

        switch selectedType {
        case .activity:
            entry.activityName = activityName
            entry.eyfsAreaRaw  = eyfsArea?.rawValue
            entry.durationMinutes = durationMinutes

        case .sleep:
            entry.sleepStart      = sleepStart
            entry.sleepEnd        = sleepEnd
            entry.sleepPositionRaw = sleepPosition.rawValue

        case .meal:
            entry.mealType       = mealType
            entry.foodOffered    = foodOffered
            entry.foodConsumedRaw = foodConsumed?.rawValue
            entry.fluidMl        = fluidMl
            entry.fluidType      = fluidType

        case .nappy:
            entry.nappyTypeRaw = nappyType.rawValue
            entry.nappyConcern = nappyConcern

        case .mood:
            entry.moodRatingRaw  = moodRating?.rawValue
            entry.checkTimeLabel = checkTimeLabel
        }

        withAnimation {
            context.insert(entry)
        }
        dismiss()
    }
}
