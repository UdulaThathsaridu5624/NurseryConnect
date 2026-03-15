// RootTabView.swift — NurseryConnect
// Root shell with two tabs: Daily Diary and Incidents.
// The app launches directly into keyworker functionality — no login required per assignment brief.

import SwiftUI
import SwiftData

struct RootTabView: View {
    @State private var selectedTab: Tab = .diary

    enum Tab: Int {
        case diary, incidents
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ChildrenListView()
            }
            .tabItem {
                Label("Daily Diary", systemImage: "book.pages.fill")
            }
            .tag(Tab.diary)

            NavigationStack {
                IncidentListView()
            }
            .tabItem {
                Label("Incidents", systemImage: "exclamationmark.triangle.fill")
            }
            .tag(Tab.incidents)
        }
        .tint(.ncPrimary)
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Child.self, DiaryEntry.self, IncidentReport.self], inMemory: true)
}
