//
//  KeyboardInputView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 14/03/26.
//

import UIKit

// THE FIX: Inherit from UIInputView, not UIView
class KeyboardInputView: UIInputView, UIInputViewAudioFeedback {
    
    init() {
        // .keyboard style instantly enforces correct native keyboard height bounds
        // preventing the full-screen stretch glitch from occurring.
        super.init(frame: .zero, inputViewStyle: .keyboard)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Allows native haptics and audio clicks to play
    var enableInputClicksWhenVisible: Bool { return true }
}
