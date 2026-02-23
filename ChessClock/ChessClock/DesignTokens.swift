import SwiftUI

// MARK: - Colors

enum ChessClockColor {
    // Board
    static let boardLight    = Color(red: 240/255, green: 217/255, blue: 181/255)
    static let boardDark     = Color(red: 181/255, green: 136/255, blue: 99/255)

    // Ring
    static let accentGold      = Color(red: 191/255, green: 155/255, blue: 48/255)
    static let accentGoldLight = Color(red: 212/255, green: 185/255, blue: 78/255)
    static let accentGoldDeep  = Color(red: 138/255, green: 111/255, blue: 31/255)
    static let accentGoldDim   = accentGold.opacity(0.30)
    static let ringTrack       = Color.gray.opacity(0.15)
    static let ringGradient    = LinearGradient(colors: [accentGoldLight, accentGoldDeep], startPoint: .topLeading, endPoint: .bottomTrailing)

    // Move highlighting
    static let moveHighlight = Color(red: 246/255, green: 246/255, blue: 104/255).opacity(0.50)

    // Selection & interaction
    static let squareSelected   = accentGold.opacity(0.30)
    static let legalDot         = accentGold.opacity(0.28)
    static let legalCapture     = accentGold.opacity(0.28)
    static let wrongFlash       = Color.red.opacity(0.40)

    // Semantic
    static let feedbackSuccess  = Color.green
    static let feedbackError    = Color.red

    // Overlays
    static let overlayScrim     = Color.black.opacity(0.45)
    static let headerBg         = Color.black.opacity(0.55)
    static let ctaBg            = Color.black.opacity(0.60)
}

// MARK: - Typography

enum ChessClockType {
    static let display = Font.system(size: 18, weight: .semibold, design: .default)
    static let title   = Font.system(size: 17, weight: .semibold, design: .default)
    static let body    = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
    static let micro   = Font.system(size: 10, weight: .medium, design: .default)
    static let mono    = Font.system(size: 11, weight: .medium, design: .monospaced)
}

// MARK: - Spacing

enum ChessClockSpace {
    static let xs: CGFloat = 2
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 12
    static let xl: CGFloat = 16
}

// MARK: - Corner Radii

enum ChessClockRadius {
    static let outer: CGFloat = 18
    static let ring: CGFloat = 12
    static let card: CGFloat = 12
    static let pill: CGFloat = 8
    static let board: CGFloat = 8
    static let badge: CGFloat = 4
}

// MARK: - Dimensions

enum ChessClockSize {
    static let app: CGFloat = 300
    static let ringStroke: CGFloat = 8
    static let ringInset: CGFloat = 6
    static let bezelGap: CGFloat = 0
    static let boardInset: CGFloat = 10
    static let board: CGFloat = 280
    static let square: CGFloat = 35
    static let boardDetail: CGFloat = 164
    static let headerHeight: CGFloat = 28
    static let overlayHeader: CGFloat = 36
    static let overlayNav: CGFloat = 32
    static let tickLength: CGFloat = 8
    static let tickWidth: CGFloat = 2.5
    static let ringOuterEdge: CGFloat = 2
    static let ringInnerEdge: CGFloat = 10
}

// MARK: - Animations

enum ChessClockAnimation {
    static let micro    = Animation.easeOut(duration: 0.12)
    static let fast     = Animation.easeOut(duration: 0.15)
    static let standard = Animation.spring(response: 0.3, dampingFraction: 0.8)
    static let smooth   = Animation.easeInOut(duration: 0.4)
    static let ring     = Animation.easeInOut(duration: 0.5)
    static let dramatic = Animation.easeInOut(duration: 0.6)
}

// MARK: - Ring Pulse Tokens

enum ChessClockPulse {
    static let width: CGFloat = 0.12           // fraction of filled arc
    static let count: Int = 2                   // concurrent pulses
    static let baseDuration: Double = 1.5       // transit seconds at progress ≈ 0
    static let scaleDuration: Double = 3.5      // added seconds at progress = 1.0
    // duration = baseDuration + scaleDuration × progress
    static let coreColor = Color.white.opacity(0.55)
    static let glowColor = ChessClockColor.accentGoldLight.opacity(0.35)
    static let innerGlowBlur: CGFloat = 4
    static let outerGlowBlur: CGFloat = 8
    static let minAbsoluteWidth: CGFloat = 0.03 // minimum trim width for very short bars
}

// MARK: - Ring Tube Tokens

enum ChessClockTube {
    static let specularHighlight = Color.white.opacity(0.20)  // inner-edge strip
    static let outerShadow = Color.black.opacity(0.08)        // outer-edge strip
    static let centerHighlight = Color.white.opacity(0.08)    // center band
}

// MARK: - Detail CTA Tokens

enum ChessClockCTADetail {
    static let fontSize: CGFloat = 11
    static let iconSize: CGFloat = 9
    static let hPadding: CGFloat = 12
    static let vPadding: CGFloat = 6
}
