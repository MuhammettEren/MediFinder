import SwiftUI

/// Circular country flag renderer that avoids emoji fallback issues.
struct CountryFlagView: View {
    let country: Country
    var size: CGFloat = 24

    var body: some View {
        flagBody
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.labelWhite.opacity(0.9), lineWidth: 1.2)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
            .accessibilityLabel(country.displayName)
    }

    @ViewBuilder
    private var flagBody: some View {
        switch country {
        case .turkey:
            ZStack {
                Color(hex: "#E30A17")
                Circle()
                    .fill(Color.labelWhite)
                    .frame(width: size * 0.38, height: size * 0.38)
                    .offset(x: -size * 0.08)
                Circle()
                    .fill(Color(hex: "#E30A17"))
                    .frame(width: size * 0.31, height: size * 0.31)
                    .offset(x: -size * 0.01)
                StarShape()
                    .fill(Color.labelWhite)
                    .frame(width: size * 0.18, height: size * 0.18)
                    .offset(x: size * 0.20)
            }
        case .germany:
            VStack(spacing: 0) {
                Color.black
                Color(hex: "#DD0000")
                Color(hex: "#FFCE00")
            }
        case .unitedKingdom:
            ZStack {
                Color(hex: "#012169")
                DiagonalStripe()
                    .stroke(Color.labelWhite, lineWidth: size * 0.22)
                DiagonalStripe()
                    .stroke(Color(hex: "#C8102E"), lineWidth: size * 0.11)
                CrossStripe()
                    .stroke(Color.labelWhite, lineWidth: size * 0.28)
                CrossStripe()
                    .stroke(Color(hex: "#C8102E"), lineWidth: size * 0.15)
            }
        case .unitedStates:
            VStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    (index.isMultiple(of: 2) ? Color(hex: "#B22234") : Color.labelWhite)
                }
            }
            .overlay(alignment: .topLeading) {
                Color(hex: "#3C3B6E")
                    .frame(width: size * 0.48, height: size * 0.46)
            }
        case .austria:
            VStack(spacing: 0) {
                Color(hex: "#ED2939")
                Color.labelWhite
                Color(hex: "#ED2939")
            }
        case .ireland:
            HStack(spacing: 0) {
                Color(hex: "#169B62")
                Color.labelWhite
                Color(hex: "#FF883E")
            }
        case .portugal:
            HStack(spacing: 0) {
                Color(hex: "#006600")
                    .frame(width: size * 0.42)
                Color(hex: "#FF0000")
            }
        case .poland:
            VStack(spacing: 0) {
                Color.labelWhite
                Color(hex: "#DC143C")
            }
        case .afghanistan:
            HStack(spacing: 0) {
                Color.black
                Color(hex: "#D32011")
                Color(hex: "#007A36")
            }
        }
    }
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = 5
        let angle = CGFloat.pi * 2 / CGFloat(points * 2)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for index in 0..<(points * 2) {
            let currentRadius = index.isMultiple(of: 2) ? radius : radius * 0.42
            let theta = CGFloat(index) * angle - CGFloat.pi / 2
            let point = CGPoint(
                x: center.x + cos(theta) * currentRadius,
                y: center.y + sin(theta) * currentRadius
            )

            index == 0 ? path.move(to: point) : path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }
}

private struct DiagonalStripe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

private struct CrossStripe: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
