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
    
    // Change the cache to use a String key for unique identification
    private var layoutCache: [String: KeyboardLayout] = [:]
    
    // Add a property to track the active language
    private var currentLanguageCode: String = "en-US"
    private var currentLayoutType: KeyboardLayoutType = .letters
    
    // Timers for native shortcuts
    private var lastShiftTapTime: TimeInterval = 0
    private var lastSpaceTapTime: TimeInterval = 0 // ADDED: For double-tap period
    
    override func loadView() {
        self.view = KeyboardInputView() // Assuming this is defined elsewhere in your project
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        setupTouchEngine()
        
        // 2. Instant Static Load (Zero Lag)
        self.currentLayoutType = .letters
        self.currentLanguageCode = "en-US"
        self.touchEngineView.applyLanguageLayout(KeyboardLayout.defaultEnglish)
        
        // 3. Seed the cache
        let key = cacheKey(for: currentLanguageCode, type: currentLayoutType)
        self.layoutCache[key] = KeyboardLayout.defaultEnglish
        
        // 4. Start loading Numbers and Symbols in the background
        prewarmLayouts(for: currentLanguageCode)
    }
    
    private func setupTouchEngine() {
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
    }
    
    private func prewarmLayouts(for language: String) {
        let allTypes: [KeyboardLayoutType] = [.letters, .numbers, .symbols]
        
        for type in allTypes {
            let filename = getFilename(for: language, type: type)
            let key = cacheKey(for: language, type: type)
            
            // Skip if already cached
            if layoutCache[key] != nil { continue }
            
            LayoutManager.loadLayoutAsync(named: filename) { [weak self] layout in
                guard let self = self, let layout = layout else { return }
                
                self.layoutCache[key] = layout
                
                // If the user tapped faster than the background thread, show it immediately
                if self.currentLanguageCode == language && self.currentLayoutType == type {
                    self.touchEngineView.applyLanguageLayout(layout)
                }
            }
        }
    }
    
    private func getFilename(for language: String, type: KeyboardLayoutType) -> String {
        switch type {
        case .letters: return language
        case .numbers: return "\(language)-numbers"
        case .symbols: return "\(language)-symbols"
        }
    }
    
    func switchLayout(to type: KeyboardLayoutType, language: String? = nil) {
        if let lang = language { self.currentLanguageCode = lang }
        self.currentLayoutType = type
        
        let key = cacheKey(for: currentLanguageCode, type: currentLayoutType)
        
        // 1. Check Cache
        if let cachedLayout = layoutCache[key] {
            self.touchEngineView.applyLanguageLayout(cachedLayout)
        } else {
            // 2. Trigger fallback load (In case they tap before prewarm finishes)
            prewarmLayouts(for: currentLanguageCode)
        }
    }
    
    // MARK: - KeyboardEngineDelegate Implementation
    
    func insertCharacter(_ text: String) {
        // NOTE: I removed UIDevice.current.playInputClick() from here
        // because you already play it inside KeyboardTouchEngineView.touchesBegan!
        
        // Layout Switching Logic
        if text == "numbers" { switchLayout(to: .numbers); return }
        if text == "letters" { switchLayout(to: .letters); return }
        if text == "symbols" { switchLayout(to: .symbols); return }
        
        // 1. Handle Control Commands
        if text == "space" || text == "" {
            // ADDED: Double-tap spacebar for period logic
            let now = Date().timeIntervalSince1970
            if (now - lastSpaceTapTime) < 0.3 {
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(". ") // TODO: - Change this for other languages
                lastSpaceTapTime = 0 // Reset to prevent triple-tap bugs
            } else {
                self.textDocumentProxy.insertText(" ")
                lastSpaceTapTime = now
            }
            return
        }
        
        if text == "return" {
            self.textDocumentProxy.insertText("\n")
            return
        }
        
        if text == "shift" {
            let now = Date().timeIntervalSince1970
            let timeSinceLastTap = now - lastShiftTapTime
            lastShiftTapTime = now
            
            if touchEngineView.currentShiftState == .capsLocked {
                touchEngineView.currentShiftState = .lowercased
            } else if timeSinceLastTap < 0.3 {
                touchEngineView.currentShiftState = .capsLocked
            } else if touchEngineView.currentShiftState == .lowercased {
                touchEngineView.currentShiftState = .uppercased
            } else {
                touchEngineView.currentShiftState = .lowercased
            }
            return
        }
        
        // 2. Insert the standard character
        self.textDocumentProxy.insertText(text)
        
        // 3. Auto-revert single-shift state
        if touchEngineView.currentShiftState == .uppercased {
            touchEngineView.currentShiftState = .lowercased
        }
    }
    
    func deleteCharacter() {
        self.textDocumentProxy.deleteBackward()
        // No input click here either, since startDeleteTimer handles it!
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
        // No input click here, handled by native OS selection feedback you added
    }
    
    func hideAlternatesPopover() {
        activeCalloutView?.removeFromSuperview()
        activeCalloutView = nil
    }
}

extension KeyboardViewController {
    private func cacheKey(for language: String, type: KeyboardLayoutType) -> String {
        return "\(language)_\(type)"
    }
}
