import AppKit
import Foundation

/// Fixes the Blackbox Terminal icon in Finder and Dock.
/// Runs EVERY time the app is opened — always ensures correct icon.
enum BlackboxIconFixer {

    static func fixOnFirstLaunch() {
        // Always run on every launch — no marker check
        // This ensures every user always gets the correct Blackbox icon
        DispatchQueue.global(qos: .background).async {
            fixIcon()
        }
    }

    private static func fixIcon() {
        let appPath = Bundle.main.bundlePath

        // Load Blackbox icon from app bundle
        guard let iconPath = Bundle.main.path(forResource: "Blackbox", ofType: "icns"),
              let rawImage = NSImage(contentsOfFile: iconPath) else { return }

        // Add ~10% padding on each side so the icon appears the same size as
        // other dock icons (matching the inset applied in DockTilePlugin).
        let image = paddedIcon(rawImage)

        // Set icon permanently via NSWorkspace (Finder reads this)
        NSWorkspace.shared.setIcon(image, forFile: appPath, options: [])

        // Also set for /Applications path in case installed there
        let appName = "Blackbox Terminal.app"
        let appsPaths = [
            "/Applications/\(appName)",
            NSString(string: "~/Applications/\(appName)").expandingTildeInPath
        ]
        for path in appsPaths {
            if FileManager.default.fileExists(atPath: path) {
                NSWorkspace.shared.setIcon(image, forFile: path, options: [])
            }
        }

        // Clear icon cache so Finder and Dock refresh immediately
        clearIconCache()

        // Restart Dock after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            restartDock()
        }
    }

    /// Returns a new NSImage with ~10% padding on each side, matching the
    /// inset used in DockTilePlugin so the icon appears the same size as
    /// other dock icons when set via NSWorkspace.
    private static func paddedIcon(_ source: NSImage) -> NSImage {
        let size = source.size
        let inset = size.width * 0.05
        let padded = NSImage(size: size)
        padded.lockFocus()
        source.draw(
            in: CGRect(x: inset, y: inset,
                       width: size.width - inset * 2,
                       height: size.height - inset * 2),
            from: .zero,
            operation: .sourceOver,
            fraction: 1.0
        )
        padded.unlockFocus()
        return padded
    }

    private static func clearIconCache() {
        // Clear system icon cache
        let cacheURL = URL(fileURLWithPath: "/Library/Caches/com.apple.iconservices.store")
        try? FileManager.default.removeItem(at: cacheURL)

        // Clear dock icon cache
        let task = Process()
        task.launchPath = "/usr/bin/find"
        task.arguments = ["/private/var/folders", "-name", "com.apple.dock.iconcache", "-delete"]
        try? task.run()
        task.waitUntilExit()
    }

    private static func restartDock() {
        let task = Process()
        task.launchPath = "/usr/bin/killall"
        task.arguments = ["Dock"]
        try? task.run()
    }
}
