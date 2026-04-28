import GhosttyKit

extension FullscreenMode {
    /// Initialize from a Ghostty fullscreen action.
    static func from(ghostty: ghostty_action_fullscreen_e) -> Self? {
        return switch ghostty {
        case BLACKBOX_FULLSCREEN_NATIVE:
                .native

        case BLACKBOX_FULLSCREEN_MACOS_NON_NATIVE:
                .nonNative

        case BLACKBOX_FULLSCREEN_MACOS_NON_NATIVE_VISIBLE_MENU:
                .nonNativeVisibleMenu

        case BLACKBOX_FULLSCREEN_MACOS_NON_NATIVE_PADDED_NOTCH:
                .nonNativePaddedNotch

        default:
            nil
        }
    }
}
