// DiaryFeedView.swift — NurseryConnect
// Chronological diary timeline for a single child, grouped by date.

import SwiftUI
import SwiftData

struct DiaryFeedView: View {
    let child: Child

    @State private var showNewEntry = false
    @State private var preselectedType: DiaryEntryType = .activity
    @State private var showDeleteConfirm = false
    @State private var entryToDelete: DiaryEntry?

    @Environment(\.modelContext) private var context

    private var sortedEntries: [DiaryEntry] {
        child.diaryEntries.sorted { $0.timestamp > $1.timestamp }
    }

    private var groupedEntries: [(String, [DiaryEntry])] {
        let grouped = Dictionary(grouping: sortedEntries) { entry in
            if Calendar.current.isDateInToday(entry.timestamp) { return "Today" }
            if Calendar.current.isDateInYesterday(entry.timestamp) { return "Yesterday" }
            return entry.timestamp.formatted(date: .abbreviated, time: .omitted)
        }
        // Sort keys: today first, then yesterday, then by date descending
        let order = ["Today", "Yesterday"]
        let keys = grouped.keys.sorted {
            let li = order.firstIndex(of: $0) ?? Int.max
            let ri = order.firstIndex(of: $1) ?? Int.max
            if li != ri { return li < ri }
            return $0 > $1
        }
        return keys.compactMap { key in
            guard let entries = grouped[key] else { return nil }
            return (key, entries.sorted { $0.timestamp > $1.timestamp })
        }
    }

    var body: some View {
        Group {
            if sortedEntries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                        ForEach(groupedEntries, id: \.0) { dateLabel, entries in
                            Section {
                                VStack(spacing: 0) {
                                    ForEach(entries) { entry in
                                        VStack(spacing: 0) {
                                            DiaryEntryRowView(entry: entry)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 10)
                                                .contextMenu {
                                                    Button(role: .destructive) {
                                                        entryToDelete = entry
                                                        showDeleteConfirm = true
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                                                .transition(.asymmetric(
                                                    insertion: .move(edge: .top).combined(with: .opacity),
                                                    removal: .opacity
                                                ))
                                            Divider().padding(.leading, 62)
                                        }
                                    }
                                }
                                .ncCard(cornerRadius: 14)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            } header: {
                                Text(dateLabel)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
                .background(Color.ncBackground)
            }
        }
        .navigationTitle("\(child.displayName)'s Diary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(DiaryEntryType.allCases, id: \.rawValue) { type in
                        Button {
                            preselectedType = type
                            showNewEntry = true
                        } label: {
                            Label(type.displayName, systemImage: type.icon)
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.ncPrimary)
                }
                .accessibilityLabel("Add diary entry")
            }
        }
        .sheet(isPresented: $showNewEntry) {
            NewDiaryEntryView(child: child, preselectedType: preselectedType)
        }
        .confirmationDialog(
            "Delete this entry?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    withAnimation { context.delete(entry) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.pages")
                .font(.system(size: 56))
                .foregroundStyle(.ncPrimary.opacity(0.35))
            Text("No Diary Entries")
                .font(.title3.weight(.semibold))
            Text("Tap + to log the first entry for \(child.displayName) today.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ncBackground)
    }
}
