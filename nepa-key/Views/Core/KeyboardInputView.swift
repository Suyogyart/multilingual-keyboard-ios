//
//  KeyboardInputView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 14/03/26.
//


import UIKit

class KeyboardInputView: UIView, UIInputViewAudioFeedback {
   // This single property is the entire protocol requirement.
   // Returning true tells iOS: "yes, honour the user's Keyboard Clicks
   // setting and play the click sound when playInputClick() is called."
   var enableInputClicksWhenVisible: Bool { return true }
}
