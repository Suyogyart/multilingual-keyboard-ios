//
//  KeyboardViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

class KeyboardViewController: UIInputViewController, KeyboardEngineDelegate, SuggestionBarDelegate {

    var touchEngineView: KeyboardTouchEngineView!
    var suggestionBar: SuggestionBarView!
    var activeCalloutView: AlternatesCalloutView?
    var activeLanguageSelectorView: LanguageSelectorView?
    
    private var customHeightConstraint: NSLayoutConstraint?
    private let suggestionEngine = WordSuggestionEngine()
    
    private var layoutCache: [String: KeyboardLayout] = [:]
    
    private var currentLanguage: KeyboardLanguage = .english
    private var currentLayoutType: KeyboardLayoutType = .letters
    
    // Timers for native shortcuts
    private var lastShiftTapTime: TimeInterval = 0
    private var lastSpaceTapTime: TimeInterval = 0
    
    override func loadView() {
        self.view = KeyboardInputView() // Assuming this is defined elsewhere in your project
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            // This forces the TouchEngineView to run layoutSubviews()
            // and consequently our new updateLayerFrames() logic.
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyUserHeightPreference()
        
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        self.overrideUserInterfaceStyle = colors.interfaceStyle
        
        // THE FIX: Completely block the system backdrop with an opaque color.
        if KeyboardSettings.shared.selectedTheme == .system {
            // For the default theme, we WANT Apple's native curved glass to show.
            self.view.backgroundColor = .clear
        } else {
            // For custom themes, we use a 100% solid color to hide the Apple backdrop.
            // This covers everything, including the bottom Safe Area.
            self.view.backgroundColor = colors.keyboardBackground
        }
        
        suggestionBar.applyTheme()
        
        // Remove any custom blur views if you added them in the previous step
        self.view.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        setupSuggestionBar()
        setupTouchEngine()
        
        let savedLanguage = KeyboardSettings.shared.selectedLanguage
        self.currentLayoutType = .letters
        self.currentLanguage = savedLanguage
        
        let defaultLayout = KeyboardLayout.defaultLayout(for: savedLanguage)
        self.touchEngineView.applyLanguageLayout(defaultLayout)
        let key = cacheKey(for: savedLanguage, type: .letters)
        self.layoutCache[key] = defaultLayout
        
        prewarmLayouts(for: savedLanguage)
        suggestionEngine.load(for: savedLanguage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentLayoutType == .letters {
            suggestionBar.updateSuggestions(suggestionEngine.starterSuggestions())
        }
    }
    
    private func setupSuggestionBar() {
        suggestionBar = SuggestionBarView()
        suggestionBar.delegate = self
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(suggestionBar)
        
        NSLayoutConstraint.activate([
            suggestionBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            suggestionBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            suggestionBar.heightAnchor.constraint(equalToConstant: SuggestionBarView.barHeight)
        ])
    }
    
    private func setupTouchEngine() {
        touchEngineView = KeyboardTouchEngineView()
        touchEngineView.delegate = self
        touchEngineView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.clipsToBounds = false
        self.view.addSubview(touchEngineView)
        
        NSLayoutConstraint.activate([
            touchEngineView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor),
            touchEngineView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            touchEngineView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            touchEngineView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
    }
    
    private func prewarmLayouts(for language: KeyboardLanguage) {
        let allTypes: [KeyboardLayoutType] = [.letters, .numbers, .symbols]
        
        for type in allTypes {
            let filename = language.filename(for: type)
            let key = cacheKey(for: language, type: type)
            
            if layoutCache[key] != nil { continue }
            
            LayoutManager.loadLayoutAsync(named: filename) { [weak self] layout in
                guard let self = self, let layout = layout else { return }
                
                self.layoutCache[key] = layout
                
                if self.currentLanguage == language && self.currentLayoutType == type {
                    self.touchEngineView.applyLanguageLayout(layout)
                }
            }
        }
    }
    
    func switchLayout(to type: KeyboardLayoutType, language: KeyboardLanguage? = nil) {
        if let lang = language { self.currentLanguage = lang }
        self.currentLayoutType = type
        
        let key = cacheKey(for: currentLanguage, type: currentLayoutType)
        
        if let cachedLayout = layoutCache[key] {
            self.touchEngineView.applyLanguageLayout(cachedLayout)
        } else {
            prewarmLayouts(for: currentLanguage)
        }
        
        let showBar = (type == .letters)
        suggestionBar.isHidden = !showBar
        if !showBar {
            suggestionBar.updateSuggestions([])
        } else {
            updateSuggestions()
        }
    }
    
    private func applyUserHeightPreference() {
        let scale = CGFloat(KeyboardSettings.shared.keyboardHeightScale)
        
        let currentBounds = self.view.window?.windowScene?.screen.bounds ?? UIScreen.main.bounds
        let isLandscape = currentBounds.width > currentBounds.height
        let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        
        let contextScreenHeight: CGFloat = currentBounds.height
        let defaultHeight: CGFloat = contextScreenHeight < 800 ? 216 : 226
        
        let barHeight = suggestionBar.isHidden ? 0 : SuggestionBarView.barHeight
        var targetHeight: CGFloat
        
        if isPhone && isLandscape {
            targetHeight = 160.0 + barHeight
        } else {
            targetHeight = defaultHeight * scale + barHeight
        }
        
        if customHeightConstraint == nil {
            customHeightConstraint = self.view.heightAnchor.constraint(equalToConstant: targetHeight)
            customHeightConstraint?.priority = UILayoutPriority(999)
            customHeightConstraint?.isActive = true
        } else {
            customHeightConstraint?.constant = targetHeight
            customHeightConstraint?.isActive = true
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
            let lastWord = currentPartialWord()
            
            // ADDED: Double-tap spacebar for period logic
            let now = Date().timeIntervalSince1970
            if (now - lastSpaceTapTime) < 0.3 {
                self.textDocumentProxy.deleteBackward()
                self.textDocumentProxy.insertText(". ") // TODO: - Change this for other languages
                lastSpaceTapTime = 0 // Reset to prevent triple-tap bugs
                suggestionBar.updateSuggestions([])
            } else {
                self.textDocumentProxy.insertText(" ")
                lastSpaceTapTime = now
                let nextWords = suggestionEngine.nextWordSuggestions(after: lastWord, limit: 5)
                suggestionBar.updateSuggestions(nextWords)
            }
            return
        }
        
        if text == "return" {
            self.textDocumentProxy.insertText("\n")
            suggestionBar.updateSuggestions([])
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
        
        updateSuggestions()
    }
    
    func deleteCharacter() {
        self.textDocumentProxy.deleteBackward()
        updateSuggestions()
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
    
    // --- Globe / Language Switching ---
    
    func switchToNextLanguage() {
        let allLanguages = KeyboardLanguage.allCases
        guard let currentIndex = allLanguages.firstIndex(of: currentLanguage) else { return }
        let nextIndex = allLanguages.index(after: currentIndex) % allLanguages.count
        switchToLanguage(allLanguages[nextIndex])
    }
    
    func showLanguageSelector(for key: KeyModel) {
        let selector = LanguageSelectorView(
            options: KeyboardLanguage.allCases,
            currentLanguage: currentLanguage,
            baseKeyFrame: key.frame,
            keyboardBounds: self.view.bounds
        )
        self.view.addSubview(selector)
        self.activeLanguageSelectorView = selector
    }
    
    func hideLanguageSelector() {
        activeLanguageSelectorView?.removeFromSuperview()
        activeLanguageSelectorView = nil
    }
    
    func handleSlideOverLanguages(at point: CGPoint) {
        activeLanguageSelectorView?.handlePan(touchPointInKeyboard: point)
    }
    
    func selectHighlightedLanguage() {
        guard let selected = activeLanguageSelectorView?.getSelectedLanguage() else { return }
        if selected != currentLanguage {
            switchToLanguage(selected)
        }
    }
    
    private func switchToLanguage(_ language: KeyboardLanguage) {
        currentLanguage = language
        KeyboardSettings.shared.selectedLanguage = language
        prewarmLayouts(for: language)
        switchLayout(to: .letters, language: language)
        suggestionEngine.load(for: language)
        suggestionBar.updateSuggestions([])
    }
    
    // MARK: - Suggestions
    
    private func updateSuggestions() {
        guard currentLayoutType == .letters else {
            suggestionBar.updateSuggestions([])
            return
        }
        
        let prefix = currentPartialWord()
        if prefix.isEmpty {
            let context = textDocumentProxy.documentContextBeforeInput ?? ""
            if context.isEmpty {
                suggestionBar.updateSuggestions(suggestionEngine.starterSuggestions())
            } else {
                suggestionBar.updateSuggestions([])
            }
            return
        }
        
        let results = suggestionEngine.suggestions(for: prefix, limit: 5)
        suggestionBar.updateSuggestions(results)
    }
    
    private func currentPartialWord() -> String {
        guard let context = textDocumentProxy.documentContextBeforeInput else { return "" }
        
        var word = ""
        for char in context.reversed() {
            if char.isLetter || char == "'" || char == "\u{2019}" {
                word.append(char)
            } else {
                break
            }
        }
        return String(word.reversed())
    }
    
    // MARK: - SuggestionBarDelegate
    
    func didSelectSuggestion(_ word: String) {
        let partial = currentPartialWord()
        for _ in 0..<partial.count {
            textDocumentProxy.deleteBackward()
        }
        textDocumentProxy.insertText(word + " ")
        let nextWords = suggestionEngine.nextWordSuggestions(after: word, limit: 5)
        suggestionBar.updateSuggestions(nextWords)
    }
}

extension KeyboardViewController {
    private func cacheKey(for language: KeyboardLanguage, type: KeyboardLayoutType) -> String {
        return "\(language.rawValue)_\(type)"
    }
}
