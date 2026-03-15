// ContentView.swift — NurseryConnect
// Entry view — delegates to RootTabView.
// Kept for Xcode preview compatibility.

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        RootTabView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Child.self, DiaryEntry.self, IncidentReport.self], inMemory: true)
}
