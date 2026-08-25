import SwiftUI

struct JourneyWeekPathView: View {
    let days: [JourneyWeekDay]

    var body: some View {
        Canvas { context, size in
            let points = nodePoints(in: size)
            guard points.count == days.count, let first = points.first else { return }

            var trail = Path()
            trail.move(to: first)
            for point in points.dropFirst() {
                trail.addLine(to: point)
            }
            context.stroke(
                trail,
                with: .color(SelahColors.text.opacity(0.12)),
                style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [1, 7])
            )

            if let lastComplete = days.lastIndex(where: \.isComplete), lastComplete > 0 {
                var walked = Path()
                walked.move(to: points[0])
                for point in points[1...lastComplete] {
                    walked.addLine(to: point)
                }
                context.stroke(
                    walked,
                    with: .color(SelahColors.accent.opacity(0.65)),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
            }

            for (index, day) in days.enumerated() {
                let point = points[index]
                let radius: CGFloat = day.isComplete ? 13 : 11
                let fill = day.isComplete ? SelahColors.accent : SelahColors.surface
                let stroke = day.isComplete ? SelahColors.accentDeep : SelahColors.text.opacity(0.14)
                let circle = Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
                context.fill(circle, with: .color(fill))
                context.stroke(circle, with: .color(stroke), lineWidth: 1.5)
                if day.isComplete {
                    var check = Path()
                    check.move(to: CGPoint(x: point.x - 4, y: point.y))
                    check.addLine(to: CGPoint(x: point.x - 1, y: point.y + 3))
                    check.addLine(to: CGPoint(x: point.x + 5, y: point.y - 3))
                    context.stroke(check, with: .color(.white), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                context.draw(
                    Text(day.label)
                        .font(SelahFont.ui(.caption2, weight: .semibold))
                        .foregroundStyle(day.isComplete ? SelahColors.accentDeep : SelahColors.textSoft),
                    at: CGPoint(x: point.x, y: point.y + 28)
                )
            }
        }
        .frame(height: 168)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(weekPathLabel)
        .accessibilityIdentifier("journey.weekPath")
    }

    private var weekPathLabel: String {
        let done = days.filter(\.isComplete).count
        return "This week’s path, \(done) of 7 days complete"
    }

    private func nodePoints(in size: CGSize) -> [CGPoint] {
        let inset: CGFloat = 18
        let usable = max(size.width - inset * 2, 1)
        return days.enumerated().map { index, _ in
            let t = CGFloat(index) / 6
            let x = inset + usable * t
            let y = size.height * 0.62 - t * (size.height * 0.28) + sin(t * 6) * 10
            return CGPoint(x: x, y: y)
        }
    }
}

struct JourneyStatsRow: View {
    let tiles: [JourneyStatTile]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(tiles) { tile in
                VStack(spacing: 4) {
                    Text(tile.value)
                        .font(SelahFont.display(.title2))
                        .foregroundStyle(SelahColors.text)
                    Text(tile.label)
                        .font(SelahFont.ui(.caption2))
                        .foregroundStyle(SelahColors.textSoft)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .padding(.horizontal, 6)
                .background(SelahColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(SelahColors.text.opacity(0.08), lineWidth: 1)
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("journey.stats")
    }
}
