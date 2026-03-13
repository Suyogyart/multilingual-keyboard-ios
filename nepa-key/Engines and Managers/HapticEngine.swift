//
//  HapticEngine.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

class HapticEngine {
    static let shared = HapticEngine()
    
    // Your toggle
    var isEnabled: Bool = true
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium) // For space/return/shift
    
    init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
    }
    
    func playTap(isSpecialKey: Bool = false) {
        guard isEnabled else { return }
        
        if isSpecialKey {
            mediumGenerator.impactOccurred()
            mediumGenerator.prepare() // Get ready for next tap
        } else {
            lightGenerator.impactOccurred()
            lightGenerator.prepare()
        }
    }
}
