//
//  HapticEngine.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

// WHY AudioServices instead of UIImpactFeedbackGenerator?
//
// UIImpactFeedbackGenerator uses Core Haptics internally, which requires
// an active AVAudioSession. Keyboard extensions are NOT granted audio session
// access by default, causing the CHHapticEngine errors in the console:
//   "Failed to set category on audio session"
//   "Error Domain=NSOSStatusErrorDomain Code=1836282486"
//
// AudioServicesPlaySystemSound bypasses Core Haptics entirely and talks
// directly to the Taptic Engine via system sound IDs — the same path
// Apple's own keyboard uses. These IDs are undocumented but stable across
// iOS versions since the Taptic Engine was introduced (iPhone 6s / iOS 9):
//
//   1519 → "peek" — light tap   (character keys)
//   1520 → "pop"  — heavier tap (space, return, shift, delete)
//   1521 → "nope" — triple pulse (errors — not used here)

import AudioToolbox

class HapticEngine {
    static let shared = HapticEngine()
    
    var isEnabled: Bool {
        return KeyboardSettings.shared.enableHaptics
    }
    
    private init() {}
    
    // 1519 ("peek") is the lightest available tap and matches
    // the feel of Apple's native keyboard most closely.
    private let tapID: SystemSoundID = 1519
    
    func playTap(isSpecialKey: Bool = false) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(tapID)
    }
}
