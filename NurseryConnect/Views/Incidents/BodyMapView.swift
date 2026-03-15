// BodyMapView.swift — NurseryConnect
// Interactive front/back body-outline diagram with tap-to-place injury markers.
// Body outline is drawn using Canvas with simplified geometric shapes.
// Markers are stored as normalised (0-1) coordinates and encoded to JSON.

import SwiftUI

struct BodyMapView: View {
    @Binding var dots: [BodyMapDot]
    @State private var activeSide: String = "front"

    private var visibleDots: [BodyMapDot] { dots.filter { $0.side == activeSide } }

    var body: some View {
        VStack(spacing: 12) {
            Picker("View", selection: $activeSide) {
                Text("Front").tag("front")
                Text("Back").tag("back")
            }
            .pickerStyle(.segmented)

            ZStack {
                // Body diagram
                GeometryReader { geo in
                    ZStack {
                        // Filled body silhouette
                        BodyOutlineCanvas(side: activeSide)
                            .fill(Color.ncPrimary.opacity(0.06))

                        // Stroked body outline (separate layer — can't chain .fill after .stroke on Shape)
                        BodyOutlineCanvas(side: activeSide)
                            .stroke(Color.ncPrimary.opacity(0.7), lineWidth: 1.5)

                        // Tap overlay for placing / removing markers
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let x = value.location.x / geo.size.width
                                        let y = value.location.y / geo.size.height
                                        guard x >= 0, x <= 1, y >= 0, y <= 1 else { return }
                                        let threshold = 0.06
                                        if let idx = dots.firstIndex(where: {
                                            $0.side == activeSide &&
                                            abs($0.x - x) < threshold &&
                                            abs($0.y - y) < threshold
                                        }) {
                                            withAnimation(.spring(duration: 0.2)) {
                                                dots.remove(at: idx)
                                            }
                                        } else {
                                            withAnimation(.spring(duration: 0.3)) {
                                                dots.append(BodyMapDot(x: x, y: y, side: activeSide))
                                            }
                                        }
                                    }
                            )

                        // Injury markers — allowsHitTesting(false) so taps pass through to gesture layer
                        ForEach(visibleDots) { dot in
                            Circle()
                                .fill(Color.ncDanger)
                                .frame(width: 14, height: 14)
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                .shadow(color: .black.opacity(0.25), radius: 3)
                                .position(
                                    x: dot.x * geo.size.width,
                                    y: dot.y * geo.size.height
                                )
                                .allowsHitTesting(false)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .frame(height: 260)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .accessibilityLabel("Body map diagram. Tap to mark injury locations. \(visibleDots.count) markers on \(activeSide) view.")

            if !dots.isEmpty {
                HStack {
                    Label("\(dots.count) marker\(dots.count == 1 ? "" : "s") placed", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.ncDanger)
                    Spacer()
                    Button("Clear all") {
                        withAnimation { dots.removeAll() }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.ncDanger)
                }
            } else {
                Text("Tap the body outline to mark injury locations. Tap again to remove.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Body outline shape

/// Draws a simplified front or back body outline using a single composite Path.
/// Coordinates are normalised to a unit square (0–1 × 0–1) and scaled by the canvas size.
private struct BodyOutlineCanvas: Shape {
    let side: String  // "front" or "back"

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        func x(_ n: Double) -> CGFloat { CGFloat(n) * w }
        func y(_ n: Double) -> CGFloat { CGFloat(n) * h }

        // Head
        let headCX = x(0.5), headCY = y(0.1), headR = x(0.09)
        path.addEllipse(in: CGRect(x: headCX - headR, y: headCY - headR,
                                    width: headR * 2, height: headR * 2))

        // Neck
        path.addRect(CGRect(x: x(0.45), y: y(0.19), width: x(0.10), height: y(0.06)))

        // Torso
        path.addRoundedRect(
            in: CGRect(x: x(0.32), y: y(0.25), width: x(0.36), height: y(0.30)),
            cornerSize: CGSize(width: x(0.04), height: y(0.03))
        )

        // Left upper arm
        path.addRoundedRect(
            in: CGRect(x: x(0.18), y: y(0.25), width: x(0.13), height: y(0.20)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )
        // Left forearm
        path.addRoundedRect(
            in: CGRect(x: x(0.14), y: y(0.46), width: x(0.12), height: y(0.19)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )

        // Right upper arm
        path.addRoundedRect(
            in: CGRect(x: x(0.69), y: y(0.25), width: x(0.13), height: y(0.20)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )
        // Right forearm
        path.addRoundedRect(
            in: CGRect(x: x(0.74), y: y(0.46), width: x(0.12), height: y(0.19)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )

        // Left thigh
        path.addRoundedRect(
            in: CGRect(x: x(0.33), y: y(0.56), width: x(0.15), height: y(0.22)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )
        // Left lower leg
        path.addRoundedRect(
            in: CGRect(x: x(0.33), y: y(0.79), width: x(0.14), height: y(0.19)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )

        // Right thigh
        path.addRoundedRect(
            in: CGRect(x: x(0.52), y: y(0.56), width: x(0.15), height: y(0.22)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )
        // Right lower leg
        path.addRoundedRect(
            in: CGRect(x: x(0.53), y: y(0.79), width: x(0.14), height: y(0.19)),
            cornerSize: CGSize(width: x(0.03), height: y(0.02))
        )

        // Back-specific: add spine marker line
        if side == "back" {
            path.move(to: CGPoint(x: x(0.50), y: y(0.26)))
            path.addLine(to: CGPoint(x: x(0.50), y: y(0.55)))
        }

        return path
    }
}
