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
            // Track layer: full ring in muted gray
            FilledRingTrack()
                .fill(ChessClockColor.ringTrack, style: FillStyle(eoFill: true))

            // Fill layer: gold gradient masked by progress wedge
            FilledRingTrack()
                .fill(ChessClockColor.ringGradient, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))

            // Glass tube overlays — masked by progress wedge
            // 1. Inner-edge specular highlight
            FilledRingTrack(outerInset: 9, innerInset: 10)
                .fill(ChessClockTube.specularHighlight, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))

            // 2. Outer-edge shadow
            FilledRingTrack(outerInset: 2, innerInset: 3)
                .fill(ChessClockTube.outerShadow, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))

            // 3. Center highlight
            FilledRingTrack(outerInset: 5, innerInset: 7)
                .fill(ChessClockTube.centerHighlight, style: FillStyle(eoFill: true))
                .mask(ProgressWedge(progress: progress))

            // Traveling pulse layer — above tube overlays, below tick marks
            if progress > 0 {
                TimelineView(.animation) { timeline in
                    pulseLayer(elapsed: timeline.date.timeIntervalSinceReferenceDate)
                }
            }

            // Cardinal tick marks on top
            tickMarks
        }
        .animation(.linear(duration: 1.0), value: second)
    }

    // MARK: - Pulse Layer

    /// Renders two concurrent traveling light pulses along the ring centerline.
    private func pulseLayer(elapsed: Double) -> some View {
        let prog = Double(progress)
        // Cycle duration scales with fill: 1.5s at low progress, ~5s at full
        let rawCycle = ChessClockPulse.baseDuration + ChessClockPulse.scaleDuration * prog
        // Organic variation
        let cycleDuration = rawCycle + sin(elapsed * 0.7) * 0.3
        let safeCycle = max(cycleDuration, 0.1)  // avoid division by zero

        // Pulse width scales with progress
        let pulseWidth = max(ChessClockPulse.width * prog, Double(ChessClockPulse.minAbsoluteWidth))

        // Phase for pulse 1 and pulse 2 (offset by 50%)
        let phase1 = (elapsed / safeCycle).truncatingRemainder(dividingBy: 1.0)
        let phase2 = (phase1 + 0.5).truncatingRemainder(dividingBy: 1.0)

        return ZStack {
            pulseStrokes(phase: phase1, progress: prog, pulseWidth: pulseWidth)
            pulseStrokes(phase: phase2, progress: prog, pulseWidth: pulseWidth)
        }
        .mask(ProgressWedge(progress: progress))
    }

    /// Renders the three layers (core, inner glow, outer glow) for a single pulse.
    private func pulseStrokes(phase: Double, progress prog: Double, pulseWidth: Double) -> some View {
        let trimPos = phase * (prog + pulseWidth)
        let trimFrom = max(0, trimPos - pulseWidth)
        let trimTo = min(prog, trimPos)
        let lineW = ChessClockSize.ringStroke

        return ZStack {
            // 1. Core
            RingCenterlinePath()
                .trim(from: CGFloat(trimFrom), to: CGFloat(trimTo))
                .stroke(ChessClockPulse.coreColor, style: StrokeStyle(lineWidth: lineW, lineCap: .butt))

            // 2. Inner glow
            RingCenterlinePath()
                .trim(from: CGFloat(trimFrom), to: CGFloat(trimTo))
                .stroke(ChessClockPulse.glowColor, style: StrokeStyle(lineWidth: lineW, lineCap: .butt))
                .blur(radius: ChessClockPulse.innerGlowBlur)

            // 3. Outer glow
            RingCenterlinePath()
                .trim(from: CGFloat(trimFrom), to: CGFloat(trimTo))
                .stroke(ChessClockPulse.glowColor, style: StrokeStyle(lineWidth: lineW, lineCap: .butt))
                .blur(radius: ChessClockPulse.outerGlowBlur)
        }
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
    /// Outer end (toward content edge) is bright, inner end (toward board) is dim.
    private func tickMark(from: CGPoint, to: CGPoint, width: CGFloat,
                          gradientStart: UnitPoint, gradientEnd: UnitPoint) -> some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .stroke(
            LinearGradient(
                colors: [Color.white.opacity(0.40), Color.white.opacity(0.15)],
                startPoint: gradientStart,
                endPoint: gradientEnd
            ),
            style: StrokeStyle(lineWidth: width, lineCap: .butt)
        )
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
