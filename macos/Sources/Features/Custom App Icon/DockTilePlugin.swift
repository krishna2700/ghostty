import AppKit

class DockTilePlugin: NSObject, NSDockTilePlugIn {
    // WARNING: An instance of this class is alive as long as Ghostty's icon is
    // in the doc (running or not!), so keep any state and processing to a
    // minimum to respect resource usage.

    private let pluginBundle = Bundle(for: DockTilePlugin.self)

    // Separate defaults based on debug vs release builds so we can test icons
    // without messing up releases.
    #if DEBUG
    private let ghosttyUserDefaults = UserDefaults(suiteName: "com.blackbox.terminal.debug")
    #else
    private let ghosttyUserDefaults = UserDefaults(suiteName: "com.blackbox.terminal")
    #endif

    private var iconChangeObserver: Any?

    /// The primary NSDockTilePlugin function.
    func setDockTile(_ dockTile: NSDockTile?) {
        // If no dock tile or no access to Ghostty defaults, we can't do anything.
        guard let dockTile, let ghosttyUserDefaults else {
            iconChangeObserver = nil
            return
        }

        // Try to restore the previous icon on launch.
        iconDidChange(ghosttyUserDefaults.appIcon, dockTile: dockTile)

        // Setup a new observer for when the icon changes so we can update. This message
        // is sent by the primary Ghostty app.
        iconChangeObserver = DistributedNotificationCenter
            .default()
            .publisher(for: .ghosttyIconDidChange)
            .map { [weak self] _ in self?.ghosttyUserDefaults?.appIcon }
            .receive(on: DispatchQueue.global())
            .sink { [weak self] newIcon in self?.iconDidChange(newIcon, dockTile: dockTile) }
    }

    private func iconDidChange(_ newIcon: AppIcon?, dockTile: NSDockTile) {
        guard let appIcon = newIcon?.image(in: pluginBundle) else {
            resetIcon(dockTile: dockTile)
            return
        }

        dockTile.setIcon(appIcon)
    }

    /// Reset the application icon and dock tile icon to the default.
    private func resetIcon(dockTile: NSDockTile) {
        let appIcon: NSImage?
        if #available(macOS 26.0, *) {
            #if DEBUG
            // Use the `Blueprint` icon to distinguish Debug from Release builds.
            appIcon = pluginBundle.image(forResource: "BlueprintImage")!
            #else
            // Reset to Ghostty.icon
            appIcon = nil
            #endif
        } else {
            // Use the bundled icon to keep the corner radius consistent with pre-Tahoe apps.
            appIcon = pluginBundle.image(forResource: "AppIconImage")!
        }
        dockTile.setIcon(appIcon)
    }
}

private extension NSDockTile {
    func setIcon(_ newIcon: NSImage?) {
        // Update the Dock tile on the main thread.
        DispatchQueue.main.async {
            guard let newIcon else {
                self.contentView = nil
                self.display()
                return
            }
            // Inset by ~10% on each side to match standard macOS dock icon padding,
            // preventing the icon from appearing oversized compared to other dock icons.
            let tileSize = self.size
            let inset = tileSize.width * 0.05
            let iconSize = CGSize(
                width: tileSize.width - inset * 2,
                height: tileSize.height - inset * 2
            )
            // Wrap in a transparent container so the dock tile background stays clear
            let container = NSView(frame: CGRect(origin: .zero, size: tileSize))
            container.wantsLayer = true
            container.layer?.backgroundColor = NSColor.clear.cgColor

            let iconView = NSImageView(frame: CGRect(origin: CGPoint(x: inset, y: inset), size: iconSize))
            iconView.wantsLayer = true
            iconView.layer?.backgroundColor = NSColor.clear.cgColor
            iconView.image = newIcon
            container.addSubview(iconView)
            self.contentView = container
            self.display()
        }
    }
}

// This is required because of the DispatchQueue call above. This doesn't
// feel right but I don't know a better way to solve this.
extension NSDockTile: @unchecked @retroactive Sendable {}
