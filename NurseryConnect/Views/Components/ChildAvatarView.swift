// ChildAvatarView.swift — NurseryConnect
// Circular avatar showing the child's initials with a teal gradient background.

import SwiftUI

struct ChildAvatarView: View {
    let child: Child
    var size: CGFloat = 52

    /// Deterministic background colour based on the child's name
    private var avatarColor: Color {
        let colors: [Color] = [.ncPrimary, .purple, .blue, .ncWarning, .pink, .teal, .indigo]
        let index = abs(child.fullName.hashValue) % colors.count
        return colors[index]
    }

    var body: some View {
        Group {
            if let name = child.photoName, let uiImage = UIImage(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(avatarColor.gradient)
                        .frame(width: size, height: size)
                    Text(child.initials)
                        .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .accessibilityLabel("\(child.displayName)'s avatar")
    }
}
