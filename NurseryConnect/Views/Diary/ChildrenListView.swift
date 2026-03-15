// ChildrenListView.swift — NurseryConnect
// Root diary screen: grid of children assigned to the current keyworker.

import SwiftUI
import SwiftData

struct ChildrenListView: View {
    @Query(sort: \Child.firstName) private var children: [Child]
    @Environment(\.modelContext) private var context

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        Group {
            if children.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerBanner
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(children) { child in
                                NavigationLink(value: child) {
                                    ChildCardView(child: child)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                .background(Color.ncBackground)
            }
        }
        .navigationTitle("My Children")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Child.self) { child in
            ChildDetailView(child: child)
        }
    }

    // MARK: - Sub-views

    private var headerBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good morning, Sarah 👋")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Text("\(children.count) children assigned today")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
            }
            Spacer()
            Image(systemName: "sun.max.fill")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.ncPrimary, .ncPrimary.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .padding(.bottom, 16)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 56))
                .foregroundStyle(.ncPrimary.opacity(0.4))
            Text("No Children Assigned")
                .font(.title3.weight(.semibold))
            Text("Children are assigned to you by the Setting Manager.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ncBackground)
    }
}

// MARK: - Child card

struct ChildCardView: View {
    let child: Child
    @State private var appeared = false

    private var todayCount: Int { child.todaysDiaryEntries.count }
    private var lastMood: MoodRating? { child.lastMoodToday }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row: avatar + allergy badge
            HStack(alignment: .top) {
                ChildAvatarView(child: child, size: 50)
                Spacer()
                if child.hasAllergies {
                    Image(systemName: "allergens")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(.ncDanger, in: Circle())
                        .accessibilityLabel("Has allergies: \(child.allergies)")
                }
            }
            .padding(.bottom, 10)

            // Name & room
            Text(child.displayName)
                .font(.headline.weight(.semibold))
                .lineLimit(1)

            Text("\(child.roomName) · \(child.age)y")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)

            Divider()

            // Today's summary
            HStack {
                Label("\(todayCount)", systemImage: "list.bullet.clipboard")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.ncPrimary)
                    .accessibilityLabel("\(todayCount) diary entries today")

                Spacer()

                if let mood = lastMood {
                    Text(mood.emoji)
                        .font(.title3)
                        .accessibilityLabel("Mood: \(mood.displayName)")
                } else {
                    Text("–")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 10)
        }
        .padding(14)
        .ncCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .onAppear {
            withAnimation(.spring(duration: 0.4).delay(0.05)) {
                appeared = true
            }
        }
    }
}
