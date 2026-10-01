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
        // .default avoids the translucent blur backdrop that .keyboard injects,
        // while still enforcing correct native keyboard height bounds.
        super.init(frame: .zero, inputViewStyle: .default)
        // Allow Auto Layout constraints to determine the keyboard height.
        self.allowsSelfSizing = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Allows native haptics and audio clicks to play
    var enableInputClicksWhenVisible: Bool { return true }
}
