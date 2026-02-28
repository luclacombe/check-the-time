import AppKit
import SwiftUI

// MARK: - BorderlessPanel

/// Borderless NSPanel subclass that can become key/main for keyboard events.
private class BorderlessPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - FloatingWindowContent

/// Wraps ClockView with hover-visible close/minimize buttons for the borderless floating window.
private struct FloatingWindowContent: View {
    let clockService: ClockService
    let onClose: () -> Void
    let onMinimize: () -> Void
    @State private var isHovering = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            ClockView(clockService: clockService)

            if isHovering {
                HStack(spacing: 6) {
                    windowButton(icon: "xmark", action: onClose)
                    windowButton(icon: "minus", action: onMinimize)
                }
                .padding(.top, 22)
                .padding(.leading, 22)
                .transition(.opacity)
            }
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.outer))
        .onHover { hovering in
            withAnimation(ChessClockAnimation.fast) { isHovering = hovering }
        }
    }

    private func windowButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 22, height: 22)
                .background(.black.opacity(0.45), in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
    }
}

// MARK: - FloatingWindowManager

/// Manages right-click context menu on the status bar icon and a detached floating panel.
@MainActor
final class FloatingWindowManager: NSObject, NSMenuDelegate {
    static let shared = FloatingWindowManager()

    private var panel: BorderlessPanel?
    private var clockService: ClockService?
    private var eventMonitor: Any?

    private lazy var contextMenu: NSMenu = {
        let menu = NSMenu()

        let floatItem = NSMenuItem(
            title: "Open as Floating Window",
            action: #selector(openFloatingWindow),
            keyEquivalent: ""
        )
        floatItem.target = self
        menu.addItem(floatItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit Chess Clock",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        quitItem.target = self
        menu.addItem(quitItem)

        menu.delegate = self
        return menu
    }()

    private override init() {}

    /// Call once (e.g. in onAppear) to begin watching right-clicks on the status bar icon.
    func setup(clockService: ClockService) {
        self.clockService = clockService
        guard eventMonitor == nil else { return }
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { [weak self] event in
            guard let self else { return event }
            // Only intercept events on our own NSStatusBarWindow
            if let window = event.window,
               NSStringFromClass(type(of: window)) == "NSStatusBarWindow" {
                Task { @MainActor in self.showContextMenuOnStatusItem() }
                return nil  // suppress default right-click handling
            }
            return event
        }
    }

    private func showContextMenuOnStatusItem() {
        let sel = NSSelectorFromString("statusItem")
        for window in NSApp.windows {
            guard NSStringFromClass(type(of: window)) == "NSStatusBarWindow",
                  window.responds(to: sel),
                  let item = window.perform(sel)?.takeUnretainedValue() as? NSStatusItem
            else { continue }
            item.menu = contextMenu
            item.button?.performClick(nil)
            return
        }
    }

    // NSMenuDelegate: clear the menu after it closes so left-click still shows the window.
    nonisolated func menuDidClose(_ menu: NSMenu) {
        Task { @MainActor in
            let sel = NSSelectorFromString("statusItem")
            for window in NSApp.windows {
                guard NSStringFromClass(type(of: window)) == "NSStatusBarWindow",
                      window.responds(to: sel),
                      let item = window.perform(sel)?.takeUnretainedValue() as? NSStatusItem
                else { continue }
                item.menu = nil
                return
            }
        }
    }

    @objc private func openFloatingWindow() { showFloatingWindow() }
    @objc private func quitApp() { NSApplication.shared.terminate(nil) }

    func showFloatingWindow() {
        if let existing = panel, existing.isVisible {
            existing.orderFront(nil)
            return
        }
        guard let clockService else { return }

        let p = BorderlessPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .floating
        p.isMovableByWindowBackground = true
        p.backgroundColor = .clear
        p.isOpaque = false
        p.hasShadow = true
        p.hidesOnDeactivate = false
        p.collectionBehavior.insert(.canJoinAllSpaces)
        p.isReleasedWhenClosed = false

        let content = FloatingWindowContent(
            clockService: clockService,
            onClose: { [weak p] in p?.close() },
            onMinimize: { [weak p] in p?.miniaturize(nil) }
        )
        p.contentView = NSHostingView(rootView: content)
        p.center()
        p.makeKeyAndOrderFront(nil)
        panel = p
    }

    deinit {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
