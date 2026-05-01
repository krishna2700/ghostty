import AppKit
import Foundation

/// Fixes the Blackbox Terminal icon in Finder and Dock on first launch.
/// Runs only once per user — never again after that.
enum BlackboxIconFixer {

    static func fixOnFirstLaunch() {
        let marker = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".blackbox_icon_fixed")

        // Only run once ever
        guard !FileManager.default.fileExists(atPath: marker.path) else { return }

        DispatchQueue.global(qos: .background).async {
            fixIcon()
            // Mark as done
            try? "done".write(to: marker, atomically: true, encoding: .utf8)
        }
    }

    private static func fixIcon() {
        guard let appPath = Bundle.main.bundlePath as String?,
              let iconPath = Bundle.main.path(forResource: "Blackbox", ofType: "icns"),
              let image = NSImage(contentsOfFile: iconPath) else { return }

        // Set icon via NSWorkspace (works for Finder)
        NSWorkspace.shared.setIcon(image, forFile: appPath, options: [])

        // Clear icon cache
        clearIconCache()

        // Restart Dock to refresh icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            restartDock()
        }
    }

    private static func clearIconCache() {
        let cacheURL = URL(fileURLWithPath: "/Library/Caches/com.apple.iconservices.store")
        try? FileManager.default.removeItem(at: cacheURL)

        // Clear user icon cache
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
