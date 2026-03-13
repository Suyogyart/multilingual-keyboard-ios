//
//  KeyboardViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

enum KeyboardLayoutType {
    case letters
    case numbers
    case symbols
}

class KeyboardViewController: UIInputViewController, KeyboardEngineDelegate {

    var touchEngineView: KeyboardTouchEngineView!
    var activeCalloutView: AlternatesCalloutView?
    
    // Tracks the time of the last shift tap
    private var lastShiftTapTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        touchEngineView = KeyboardTouchEngineView()
        touchEngineView.delegate = self
        touchEngineView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.clipsToBounds = false
        self.view.addSubview(touchEngineView)
        
        NSLayoutConstraint.activate([
            touchEngineView.topAnchor.constraint(equalTo: self.view.topAnchor),
            touchEngineView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            touchEngineView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            touchEngineView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
        
        switchLayout(to: .letters)
    }
    
    // Replace the old private func loadEnglishLayout() with this:
    private func switchLayout(to type: KeyboardLayoutType) {
        let filename: String
        
        switch type {
        case .letters:
            filename = "en-US"
        case .numbers:
            filename = "en-US-numbers"
        case .symbols:
            filename = "en-US-symbols" // Make sure to create this file later!
        }
        
        if let layout = LayoutManager.loadLayout(named: filename) {
            // This immediately wipes the old UI and mathematically draws the new grid!
            self.touchEngineView.applyLanguageLayout(layout)
        } else {
            print("Critical Error: Failed to load \(filename).json")
        }
    }
    
    // MARK: - KeyboardEngineDelegate Implementation
    
    func insertCharacter(_ text: String) {
        
        // Layout Switching Logic
        if text == "numbers" {
            switchLayout(to: .numbers)
            UIDevice.current.playInputClick()
            return
        }
        
        if text == "letters" {
            switchLayout(to: .letters)
            UIDevice.current.playInputClick()
            return
        }
        
        if text == "symbols" {
            switchLayout(to: .symbols)
            UIDevice.current.playInputClick()
            return
        }
        
        // 1. Handle Control Commands
        if text == "space" || text == "" {
            self.textDocumentProxy.insertText(" ")
            UIDevice.current.playInputClick()
            return
        }
        
        if text == "return" {
            self.textDocumentProxy.insertText("\n")
            UIDevice.current.playInputClick()
            return
        }
        
        if text == "shift" {
            // Calculate time since last tap
            let now = Date().timeIntervalSince1970
            let timeSinceLastTap = now - lastShiftTapTime
            lastShiftTapTime = now
            
            if touchEngineView.currentShiftState == .capsLocked {
                // If already locked, ANY tap unlocks it
                touchEngineView.currentShiftState = .lowercased
            } else if timeSinceLastTap < 0.3 {
                // Double tap detected (less than 0.3 seconds)! Lock it.
                touchEngineView.currentShiftState = .capsLocked
            } else if touchEngineView.currentShiftState == .lowercased {
                // Single tap to turn on
                touchEngineView.currentShiftState = .uppercased
            } else {
                // Single tap to turn off
                touchEngineView.currentShiftState = .lowercased
            }
            return
        }
        
        // 2. Insert the standard character (already resolved by TouchEngineView)
        self.textDocumentProxy.insertText(text)
        UIDevice.current.playInputClick()
        
        // 3. Auto-revert single-shift state
        if touchEngineView.currentShiftState == .uppercased {
            touchEngineView.currentShiftState = .lowercased
        }
    }
    
    func deleteCharacter() {
        self.textDocumentProxy.deleteBackward()
        UIDevice.current.playInputClick()
    }
    
    // --- Alternate Popover Handling ---
    
    func showAlternatesPopover(for key: KeyModel) {
        let callout = AlternatesCalloutView(alternates: key.alternates, baseKeyFrame: key.frame, keyboardBounds: self.view.bounds)
        self.view.addSubview(callout)
        self.activeCalloutView = callout
    }
    
    func handleSlideOverAlternates(at point: CGPoint) {
        activeCalloutView?.handlePan(touchPointInKeyboard: point)
    }
    
    func insertSelectedAlternateCharacter() {
        guard let char = activeCalloutView?.getSelectedCharacter() else { return }
        self.textDocumentProxy.insertText(char)
        UIDevice.current.playInputClick()
    }
    
    func hideAlternatesPopover() {
        activeCalloutView?.removeFromSuperview()
        activeCalloutView = nil
    }
}
