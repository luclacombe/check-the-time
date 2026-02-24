import SwiftUI

// MARK: - FilledRingTrack

/// Draws the filled area between two concentric rounded rects.
/// Use with `FillStyle(eoFill: true)` to punch the inner rect out.
struct FilledRingTrack: Shape {
    var outerInset: CGFloat = ChessClockSize.ringOuterEdge  // 2pt default
    var innerInset: CGFloat = ChessClockSize.ringInnerEdge  // 10pt default

    func path(in rect: CGRect) -> Path {
        let outerRadius = ChessClockRadius.outer - outerInset
        let innerRadius = ChessClockRadius.outer - innerInset

        var path = Path()

        // Outer rounded rect (clockwise winding)
        let outerRect = rect.insetBy(dx: outerInset, dy: outerInset)
        path.addRoundedRect(in: outerRect, cornerSize: CGSize(width: outerRadius, height: outerRadius))

        // Inner rounded rect (counter-clockwise winding — even-odd rule punches it out)
        let innerRect = rect.insetBy(dx: innerInset, dy: innerInset)
        path.addRoundedRect(in: innerRect, cornerSize: CGSize(width: innerRadius, height: innerRadius))

        return path
    }
}

// MARK: - ProgressWedge

/// Pie-wedge mask that grows clockwise from 12 o'clock.
/// Use as a `.mask(_:)` over the filled ring gradient layer.
struct ProgressWedge: Shape, Animatable {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        // Guard: full frame visible when progress >= 1.0
        guard progress < 1.0 else {
            return Path(rect)
        }
        guard progress > 0 else {
            return Path()
        }

        let center = CGPoint(x: rect.midX, y: rect.midY)
        // Use the diagonal half-length so the wedge always covers the ring corners
        let radius = sqrt(rect.width * rect.width + rect.height * rect.height) / 2

        // 12 o'clock = -90°; sweep clockwise.
        // In SwiftUI's coordinate space (y-down), clockwise = increasing angle,
        // so we use clockwise: false (the arc parameter is inverted vs UIKit).
        let startAngle = Angle.degrees(-90)
        let endAngle   = Angle.degrees(-90 + Double(progress) * 360)

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - RingCenterlinePath

/// Traces the centerline of the ring track as a rounded rect.
/// Starts at top-center and proceeds clockwise, so `trim(from: 0, to: x)`
/// maps from 12 o'clock clockwise — matching `ProgressWedge` angular semantics.
struct RingCenterlinePath: Shape {
    func path(in rect: CGRect) -> Path {
        let inset: CGFloat = 6    // 6pt from content edge
        let r: CGFloat = 12       // 12pt corner radius

        let left   = rect.minX + inset
        let right  = rect.maxX - inset
        let top    = rect.minY + inset
        let bottom = rect.maxY - inset
        let midX   = rect.midX

        var path = Path()

        // Start at top-center
        path.move(to: CGPoint(x: midX, y: top))

        // → Right along top edge
        path.addLine(to: CGPoint(x: right - r, y: top))

        // ↘ Top-right arc (90°)
        path.addArc(
            center: CGPoint(x: right - r, y: top + r),
            radius: r,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )

        // ↓ Down right edge
        path.addLine(to: CGPoint(x: right, y: bottom - r))

        // ↙ Bottom-right arc (90°)
        path.addArc(
            center: CGPoint(x: right - r, y: bottom - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        // ← Left along bottom edge
        path.addLine(to: CGPoint(x: left + r, y: bottom))

        // ↖ Bottom-left arc (90°)
        path.addArc(
            center: CGPoint(x: left + r, y: bottom - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )

        // ↑ Up left edge
        path.addLine(to: CGPoint(x: left, y: top + r))

        // ↗ Top-left arc (90°)
        path.addArc(
            center: CGPoint(x: left + r, y: top + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )

        // Close back to top-center
        path.addLine(to: CGPoint(x: midX, y: top))

        return path
    }
}

// MARK: - MinuteBezelView

struct MinuteBezelView: View {
    let minute: Int
    let second: Int

    /// Continuous progress 0.0 … ~0.9997 — advances every second.
    private var progress: CGFloat { CGFloat(minute * 60 + second) / 3600.0 }

    var body: some View {
        ZStack {
            // 1. Track layer: full ring in muted gray
            FilledRingTrack()
                .fill(ChessClockColor.ringTrack, style: FillStyle(eoFill: true))

            // 2. Animated fill group (scoped animation for smooth sweep)
            fillGroup
                .animation(.linear(duration: 1.0), value: second)

            // 3. Energy pulse — one-directional, constant width, glowing
            //    Uses TimelineView (safe — outside the .animation scope)
            if progress > 0 {
                TimelineView(.animation) { timeline in
                    energyPulse(elapsed: timeline.date.timeIntervalSinceReferenceDate)
                }
            }

            // 4. Cardinal tick marks on top (static)
            tickMarks
        }
    }

    // MARK: - Fill Group

    private var fillGroup: some View {
        ZStack {
            FilledRingTrack()
                .fill(ChessClockColor.ringGradient, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))

            FilledRingTrack(outerInset: 9, innerInset: 10)
                .fill(ChessClockTube.specularHighlight, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))

            FilledRingTrack(outerInset: 2, innerInset: 3)
                .fill(ChessClockTube.outerShadow, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))
        }
    }

    // MARK: - Energy Pulse

    /// Three overlapping glowing pulses at different speeds create an organic
    /// energy-flow effect. All are heavily blurred — no sharp edges.
    /// The ProgressWedge mask handles the diagonal end clipping, not the trim math.
    private func energyPulse(elapsed: Double) -> some View {
        let prog = Double(progress)

        return ZStack {
            // Primary warm glow — medium speed
            singlePulse(elapsed: elapsed, speed: 4.5, width: 0.06,
                         color: ChessClockColor.accentGoldLight.opacity(0.45),
                         lineW: ChessClockSize.ringStroke + 6, blurR: 6, prog: prog)

            // Slow ambient wash — wider, softer
            singlePulse(elapsed: elapsed, speed: 7.0, width: 0.08,
                         color: Color.white.opacity(0.28),
                         lineW: ChessClockSize.ringStroke + 4, blurR: 8, prog: prog)

            // Fast accent spark — narrow, bright
            singlePulse(elapsed: elapsed, speed: 3.0, width: 0.04,
                         color: ChessClockColor.accentGoldLight.opacity(0.35),
                         lineW: ChessClockSize.ringStroke, blurR: 5, prog: prog)
        }
        .mask(ProgressWedge(progress: progress))
    }

    /// Renders a single diffused energy pulse. trimTo extends past prog — the
    /// ProgressWedge mask clips at the diagonal end. Opacity fades in smoothly
    /// as the pulse enters at 12 o'clock for a gentle start.
    private func singlePulse(elapsed: Double, speed: Double, width: Double,
                              color: Color, lineW: CGFloat, blurR: CGFloat,
                              prog: Double) -> some View {
        let phase = (elapsed / speed).truncatingRemainder(dividingBy: 1.0)
        let range = prog + width
        let center = phase * range
        let trimFrom = CGFloat(max(0, center - width / 2))
        let trimTo = CGFloat(min(1.0, center + width / 2))

        // Smooth fade-in: pulse brightens over its first width of travel
        let fadeIn = min(1.0, center / width)

        return RingCenterlinePath()
            .trim(from: trimFrom, to: max(trimFrom, trimTo))
            .stroke(color, style: StrokeStyle(lineWidth: lineW, lineCap: .round))
            .blur(radius: blurR)
            .opacity(fadeIn)
    }

    // MARK: - Tick Marks

    private var tickMarks: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let outerEdge = ChessClockSize.ringOuterEdge  // 2pt — tick outer end
            let innerEdge = ChessClockSize.ringInnerEdge  // 10pt — tick inner end
            let tickW = ChessClockSize.tickWidth

            // Top tick (12 o'clock) — vertical, outer is at top
            tickMark(
                from: CGPoint(x: w / 2, y: outerEdge),
                to:   CGPoint(x: w / 2, y: innerEdge),
                width: tickW,
                gradientStart: .top,
                gradientEnd: .bottom
            )

            // Right tick (3 o'clock) — horizontal, outer is at right
            tickMark(
                from: CGPoint(x: w - outerEdge, y: h / 2),
                to:   CGPoint(x: w - innerEdge, y: h / 2),
                width: tickW,
                gradientStart: .trailing,
                gradientEnd: .leading
            )

            // Bottom tick (6 o'clock) — vertical, outer is at bottom
            tickMark(
                from: CGPoint(x: w / 2, y: h - outerEdge),
                to:   CGPoint(x: w / 2, y: h - innerEdge),
                width: tickW,
                gradientStart: .bottom,
                gradientEnd: .top
            )

            // Left tick (9 o'clock) — horizontal, outer is at left
            tickMark(
                from: CGPoint(x: outerEdge, y: h / 2),
                to:   CGPoint(x: innerEdge, y: h / 2),
                width: tickW,
                gradientStart: .leading,
                gradientEnd: .trailing
            )
        }
    }

    /// Draws a single tick mark with a gradient along its length.
    /// Brighter at the outer edge, dimmer toward the board. Casts a shadow
    /// onto the ring below so ticks appear raised above the gold surface.
    private func tickMark(from: CGPoint, to: CGPoint, width: CGFloat,
                          gradientStart: UnitPoint, gradientEnd: UnitPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(
            LinearGradient(
                colors: [Color.white.opacity(0.70), Color.white.opacity(0.30)],
                startPoint: gradientStart,
                endPoint: gradientEnd
            ),
            style: StrokeStyle(lineWidth: width, lineCap: .butt)
        )
        .shadow(color: Color.black.opacity(0.40), radius: 1.5, x: 0, y: 0)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        ForEach([0, 15, 30, 45, 59], id: \.self) { min in
            VStack(spacing: 4) {
                Text("minute = \(min)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ZStack {
                    Rectangle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 300, height: 300)
                    MinuteBezelView(minute: min, second: 0)
                        .frame(width: 300, height: 300)
                }
            }
        }
    }
    .padding(32)
}
