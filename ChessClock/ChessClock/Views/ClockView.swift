import AppKit
import SwiftUI

// MARK: - View mode

private enum ViewMode { case clock, info, puzzle, replay }

// MARK: - ClockView

struct ClockView: View {
    @ObservedObject var clockService: ClockService
    @StateObject private var guessService: GuessService
    @State private var showOnboarding = OnboardingService.shouldShowOnboarding
    @State private var viewMode: ViewMode = .clock
    @State private var isHovering = false

    init(clockService: ClockService) {
        self.clockService = clockService
        self._guessService = StateObject(wrappedValue: GuessService(clockService: clockService))
    }

    var body: some View {
        ZStack {
            switch viewMode {
            case .clock:
                boardWithRing
            case .info:
                InfoPanelView(
                    state: clockService.state,
                    guessService: guessService,
                    onBack: { viewMode = .clock },
                    onGuess: { viewMode = .puzzle }
                )
            case .puzzle:
                GuessMoveView(
                    state: clockService.state,
                    guessService: guessService,
                    onBack: { viewMode = .info },
                    onReplay: { viewMode = .replay }
                )
            case .replay:
                GameReplayView(
                    game: clockService.state.game,
                    hour: clockService.state.hour,
                    isFlipped: clockService.state.isFlipped,
                    onBack: { viewMode = .info }
                )
            }

            if showOnboarding {
                OnboardingOverlayView {
                    OnboardingService.dismissOnboarding()
                    showOnboarding = false
                }
            }
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.outer))
        // Reset to clock whenever this MenuBarExtra window becomes key (popover reopens)
        .background(WindowObserver { viewMode = .clock })
    }

    // MARK: - Board + ring (clock / glance)

    private var boardWithRing: some View {
        ZStack {
            // Layer 1: minute bezel ring — always visible, never blurred
            MinuteBezelView(minute: clockService.state.minute)

            // Layer 2: chess board (280×280) — blurs on hover (Glance face)
            BoardView(fen: clockService.state.fen, isFlipped: clockService.state.isFlipped)
                .frame(width: 280, height: 280)
                .blur(radius: isHovering ? 8 : 0)
                .animation(.easeInOut(duration: isHovering ? 0.2 : 0.15), value: isHovering)

            // Layer 3: glance pill — centered, fades in on hover
            GlassPillView {
                VStack(spacing: ChessClockSpace.xs) {
                    Text("\(clockService.state.hour):\(String(format: "%02d", clockService.state.minute)) \(clockService.state.isAM ? "AM" : "PM")")
                        .font(ChessClockType.display)
                        .foregroundStyle(.primary)
                    Text("Mate in \(clockService.state.hour)")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: isHovering ? 0.15 : 0.1), value: isHovering)
        }
        .frame(width: 300, height: 300)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .onTapGesture { viewMode = .info }
    }
}

// MARK: - WindowObserver (P5.2)
// Fires onBecomeKey whenever THIS specific window (our MenuBarExtra popover)
// becomes the key window — i.e., when the user clicks the menu bar icon to open it.
// Uses the window identity of the view's own NSWindow, not all windows globally.

private struct WindowObserver: NSViewRepresentable {
    let onBecomeKey: () -> Void

    func makeNSView(context: Context) -> _ObservingView {
        _ObservingView(onBecomeKey: onBecomeKey)
    }

    func updateNSView(_ nsView: _ObservingView, context: Context) {
        nsView.onBecomeKey = onBecomeKey
    }

    final class _ObservingView: NSView {
        var onBecomeKey: (() -> Void)?
        private var observer: NSObjectProtocol?

        init(onBecomeKey: @escaping () -> Void) {
            self.onBecomeKey = onBecomeKey
            super.init(frame: .zero)
        }
        required init?(coder: NSCoder) { fatalError() }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let win = window {
                observer = NotificationCenter.default.addObserver(
                    forName: NSWindow.didBecomeKeyNotification,
                    object: win,
                    queue: .main
                ) { [weak self] _ in self?.onBecomeKey?() }
            }
        }

        deinit {
            if let obs = observer { NotificationCenter.default.removeObserver(obs) }
        }
    }
}

#Preview {
    ClockView(clockService: ClockService())
}
