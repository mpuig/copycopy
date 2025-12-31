import Cocoa
import ApplicationServices

struct CopyKeyEvent {
    let timestamp: TimeInterval
    let appName: String
    let bundleID: String?
    let pid: pid_t
}

final class CopyEventTap {
    var doublePressThreshold: TimeInterval = 0.28

    var onCopyKeyDown: ((CopyKeyEvent) -> Void)?
    var onDoubleCopy: ((CopyKeyEvent) -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var lastCopyTimestamp: TimeInterval?

    func start() -> Bool {
        guard eventTap == nil else {
            print("[CopyEventTap] Already running")
            return true
        }

        print("[CopyEventTap] Starting event tap...")
        let mask = (1 << CGEventType.keyDown.rawValue)
        let callback: CGEventTapCallBack = { proxy, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }

            let tap = Unmanaged<CopyEventTap>.fromOpaque(userInfo).takeUnretainedValue()
            switch type {
            case .tapDisabledByTimeout, .tapDisabledByUserInput:
                tap.enableIfNeeded()
            case .keyDown:
                tap.handleKeyDown(event)
            default:
                break
            }
            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        ) else {
            print("[CopyEventTap] ❌ Failed to create event tap - check Accessibility/Input Monitoring permissions")
            return false
        }
        print("[CopyEventTap] ✅ Event tap created successfully")

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func stop() {
        guard let eventTap else { return }
        CGEvent.tapEnable(tap: eventTap, enable: false)

        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
        self.eventTap = nil
    }

    private func enableIfNeeded() {
        guard let eventTap else { return }
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    private func handleKeyDown(_ event: CGEvent) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        let cKeyCode: Int64 = 8
        guard keyCode == cKeyCode else { return }
        guard flags.contains(.maskCommand) else { return }

        let now = CACurrentMediaTime()
        print("[CopyEventTap] ⌘C detected at \(now)")

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let frontmost = NSWorkspace.shared.frontmostApplication
            let copyEvent = CopyKeyEvent(
                timestamp: now,
                appName: frontmost?.localizedName ?? "Unknown App",
                bundleID: frontmost?.bundleIdentifier,
                pid: frontmost?.processIdentifier ?? 0
            )

            self.onCopyKeyDown?(copyEvent)

            if let last = self.lastCopyTimestamp, (now - last) <= self.doublePressThreshold {
                let interval = now - last
                print("[CopyEventTap] 🎯 Double ⌘C detected! Interval: \(String(format: "%.0f", interval * 1000))ms (threshold: \(String(format: "%.0f", self.doublePressThreshold * 1000))ms)")
                self.onDoubleCopy?(copyEvent)
                self.lastCopyTimestamp = nil
            } else {
                if let last = self.lastCopyTimestamp {
                    let interval = now - last
                    print("[CopyEventTap] Too slow: \(String(format: "%.0f", interval * 1000))ms > \(String(format: "%.0f", self.doublePressThreshold * 1000))ms threshold")
                }
                self.lastCopyTimestamp = now
            }
        }
    }
}
