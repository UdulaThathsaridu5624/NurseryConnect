// BodyMapView.swift — NurseryConnect
// Interactive front/back body-outline diagram with tap-to-place injury markers.

import SwiftUI

// MARK: - Interactive body map (used in NewIncidentReportView)

struct BodyMapView: View {
    @Binding var dots: [BodyMapDot]
    @State private var activeSide: String = "front"
    @State private var pulse = false

    private var visibleDots: [BodyMapDot] { dots.filter { $0.side == activeSide } }

    var body: some View {
        VStack(spacing: 12) {
            Picker("View", selection: $activeSide) {
                Text("Front").tag("front")
                Text("Back").tag("back")
            }
            .pickerStyle(.segmented)

            ZStack {
                // Dot-grid background
                Canvas { ctx, size in
                    let spacing: CGFloat = 20
                    var col: CGFloat = spacing
                    while col < size.width {
                        var row: CGFloat = spacing
                        while row < size.height {
                            let dot = Path(ellipseIn: CGRect(x: col - 1, y: row - 1, width: 2, height: 2))
                            ctx.fill(dot, with: .color(Color.ncPrimary.opacity(0.06)))
                            row += spacing
                        }
                        col += spacing
                    }
                }

                GeometryReader { geo in
                    ZStack {
                        // Body silhouette — warm fill
                        BodySilhouette(side: activeSide)
                            .fill(Color(red: 0.97, green: 0.90, blue: 0.84).opacity(0.85))

                        // Silhouette outline
                        BodySilhouette(side: activeSide)
                            .stroke(Color.ncPrimary.opacity(0.50), lineWidth: 1.6)

                        // Body zone labels
                        Canvas { ctx, size in
                            let labels: [(String, Double, Double)] = [
                                ("Head",   0.50, 0.08),
                                ("Torso",  0.50, 0.38),
                                ("L Arm",  0.16, 0.37),
                                ("R Arm",  0.84, 0.37),
                                ("L Leg",  0.38, 0.72),
                                ("R Leg",  0.62, 0.72),
                            ]
                            for (label, nx, ny) in labels {
                                let pt = CGPoint(x: nx * size.width, y: ny * size.height)
                                let text = Text(label)
                                    .font(.system(size: 7.5, weight: .medium))
                                    .foregroundStyle(Color.ncSecondary.opacity(0.7))
                                ctx.draw(text, at: pt, anchor: .center)
                            }
                        }
                        .allowsHitTesting(false)

                        // Tap gesture to place / remove markers
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { value in
                                        let nx = value.location.x / geo.size.width
                                        let ny = value.location.y / geo.size.height
                                        let threshold = 0.06
                                        if let idx = dots.firstIndex(where: {
                                            $0.side == activeSide &&
                                            abs($0.x - nx) < threshold &&
                                            abs($0.y - ny) < threshold
                                        }) {
                                            withAnimation(.spring(duration: 0.2)) { dots.remove(at: idx) }
                                        } else {
                                            withAnimation(.spring(duration: 0.3)) {
                                                dots.append(BodyMapDot(x: nx, y: ny, side: activeSide))
                                            }
                                        }
                                    }
                            )

                        // Injury markers with pulse ring
                        ForEach(visibleDots) { dot in
                            ZStack {
                                Circle()
                                    .fill(Color.ncDanger.opacity(0.25))
                                    .frame(width: 22, height: 22)
                                    .scaleEffect(pulse ? 1.4 : 1.0)
                                Circle()
                                    .fill(Color.ncDanger)
                                    .frame(width: 12, height: 12)
                                    .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                    .shadow(color: Color.ncDanger.opacity(0.4), radius: 3)
                            }
                            .position(x: dot.x * geo.size.width, y: dot.y * geo.size.height)
                            .allowsHitTesting(false)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .frame(height: 280)
            .background(Color.ncCard, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.ncPrimary.opacity(0.12), lineWidth: 1)
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            .accessibilityLabel("Body map. Tap to mark injury locations. \(visibleDots.count) marker\(visibleDots.count == 1 ? "" : "s") on \(activeSide).")

            // Footer hint / marker count
            if !dots.isEmpty {
                HStack {
                    Label("\(dots.count) marker\(dots.count == 1 ? "" : "s") placed",
                          systemImage: "circle.fill")
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
                Text("Tap the body outline to mark injury locations. Tap a marker to remove it.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Read-only body map (used in IncidentDetailView)

struct ReadOnlyBodyMapView: View {
    let dots: [BodyMapDot]
    @State private var activeSide: String = "front"

    private var visibleDots: [BodyMapDot] { dots.filter { $0.side == activeSide } }

    var body: some View {
        VStack(spacing: 8) {
            Picker("", selection: $activeSide) {
                Text("Front").tag("front")
                Text("Back").tag("back")
            }
            .pickerStyle(.segmented)

            ZStack {
                Canvas { ctx, size in
                    let spacing: CGFloat = 20
                    var col: CGFloat = spacing
                    while col < size.width {
                        var row: CGFloat = spacing
                        while row < size.height {
                            let dot = Path(ellipseIn: CGRect(x: col - 1, y: row - 1, width: 2, height: 2))
                            ctx.fill(dot, with: .color(Color.ncPrimary.opacity(0.06)))
                            row += spacing
                        }
                        col += spacing
                    }
                }

                GeometryReader { geo in
                    ZStack {
                        BodySilhouette(side: activeSide)
                            .fill(Color(red: 0.97, green: 0.90, blue: 0.84).opacity(0.85))
                        BodySilhouette(side: activeSide)
                            .stroke(Color.ncPrimary.opacity(0.50), lineWidth: 1.6)

                        Canvas { ctx, size in
                            let labels: [(String, Double, Double)] = [
                                ("Head",   0.50, 0.08),
                                ("Torso",  0.50, 0.38),
                                ("L Arm",  0.16, 0.37),
                                ("R Arm",  0.84, 0.37),
                                ("L Leg",  0.38, 0.72),
                                ("R Leg",  0.62, 0.72),
                            ]
                            for (label, nx, ny) in labels {
                                let pt = CGPoint(x: nx * size.width, y: ny * size.height)
                                let text = Text(label)
                                    .font(.system(size: 7.5, weight: .medium))
                                    .foregroundStyle(Color.ncSecondary.opacity(0.7))
                                ctx.draw(text, at: pt, anchor: .center)
                            }
                        }

                        ForEach(visibleDots) { dot in
                            Circle()
                                .fill(Color.ncDanger)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(.white, lineWidth: 1.5))
                                .shadow(color: Color.ncDanger.opacity(0.4), radius: 2)
                                .position(x: dot.x * geo.size.width, y: dot.y * geo.size.height)
                        }
                    }
                }
            }
            .frame(height: 200)
            .background(Color.ncCard, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.ncPrimary.opacity(0.12), lineWidth: 1)
            )
        }
    }
}

// MARK: - Shared body silhouette shape

/// Connected human figure. Segments overlap slightly so there are no visible
/// gaps between head/neck/torso/limbs — giving a unified silhouette.
struct BodySilhouette: Shape {
    let side: String

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        func x(_ n: Double) -> CGFloat { CGFloat(n) * w }
        func y(_ n: Double) -> CGFloat { CGFloat(n) * h }
        func sz(_ nw: Double, _ nh: Double) -> CGSize { CGSize(width: x(nw), height: y(nh)) }

        // Head — overlaps neck top
        p.addEllipse(in: CGRect(x: x(0.41), y: y(0.01), width: x(0.18), height: y(0.19)))

        // Neck — overlaps head bottom and torso top
        p.addRoundedRect(
            in: CGRect(x: x(0.455), y: y(0.17), width: x(0.09), height: y(0.10)),
            cornerSize: sz(0.02, 0.015)
        )

        // Torso — wider, overlaps limb tops
        p.addRoundedRect(
            in: CGRect(x: x(0.30), y: y(0.24), width: x(0.40), height: y(0.32)),
            cornerSize: sz(0.05, 0.04)
        )

        // Left upper arm (extends into torso edge)
        p.addRoundedRect(
            in: CGRect(x: x(0.16), y: y(0.24), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )
        // Left forearm
        p.addRoundedRect(
            in: CGRect(x: x(0.13), y: y(0.44), width: x(0.13), height: y(0.21)),
            cornerSize: sz(0.04, 0.03)
        )

        // Right upper arm
        p.addRoundedRect(
            in: CGRect(x: x(0.69), y: y(0.24), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )
        // Right forearm
        p.addRoundedRect(
            in: CGRect(x: x(0.74), y: y(0.44), width: x(0.13), height: y(0.21)),
            cornerSize: sz(0.04, 0.03)
        )

        // Left thigh (top overlaps torso bottom)
        p.addRoundedRect(
            in: CGRect(x: x(0.31), y: y(0.53), width: x(0.17), height: y(0.24)),
            cornerSize: sz(0.04, 0.03)
        )
        // Left lower leg
        p.addRoundedRect(
            in: CGRect(x: x(0.32), y: y(0.75), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )

        // Right thigh
        p.addRoundedRect(
            in: CGRect(x: x(0.52), y: y(0.53), width: x(0.17), height: y(0.24)),
            cornerSize: sz(0.04, 0.03)
        )
        // Right lower leg
        p.addRoundedRect(
            in: CGRect(x: x(0.53), y: y(0.75), width: x(0.15), height: y(0.22)),
            cornerSize: sz(0.04, 0.03)
        )

        // Back view: spine indicator
        if side == "back" {
            p.move(to: CGPoint(x: x(0.50), y: y(0.27)))
            p.addLine(to: CGPoint(x: x(0.50), y: y(0.54)))
        }

        return p
    }
}
