// NurseryConnectApp.swift — NurseryConnect
// App entry point. Configures SwiftData with the three domain models and seeds demo data on first launch.

import SwiftUI
import SwiftData

@main
struct NurseryConnectApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Child.self,
            DiaryEntry.self,
            IncidentReport.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .onAppear {
                    // Seed demo children and diary entries on first launch
                    SampleDataSeeder.seedIfNeeded(context: sharedModelContainer.mainContext)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
