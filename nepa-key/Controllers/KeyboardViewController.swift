//
//  KeyboardViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

class KeyboardViewController: UIInputViewController, KeyboardEngineDelegate, SuggestionBarDelegate, EmojiKeyboardDelegate {

    var touchEngineView: KeyboardTouchEngineView!
    var suggestionBar: SuggestionBarView!
    var emojiKeyboardView: EmojiKeyboardView?
    var activeCalloutView: AlternatesCalloutView?
    var activeLanguageSelectorView: LanguageSelectorView?
    
    private var customHeightConstraint: NSLayoutConstraint?
    private var suggestionBarHeightConstraint: NSLayoutConstraint?
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
        
        refreshSuggestionBarVisibility()
        applyUserHeightPreference()
        
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        self.overrideUserInterfaceStyle = colors.interfaceStyle
        
        if !KeyboardSettings.shared.enableKeyboardBackground {
            self.view.backgroundColor = .clear
        } else if KeyboardSettings.shared.selectedTheme == .system {
            self.view.backgroundColor = .clear
        } else {
            self.view.backgroundColor = colors.keyboardBackground
        }
        
        suggestionBar.applyTheme()
        
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
        if savedLanguage.hasSuggestions {
            suggestionEngine.load(for: savedLanguage)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldShowSuggestionBar {
            suggestionBar.updateSuggestions(suggestionEngine.starterSuggestions())
        }
    }
    
    private func setupSuggestionBar() {
        suggestionBar = SuggestionBarView()
        suggestionBar.delegate = self
        suggestionBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(suggestionBar)
        
        let heightConstraint = suggestionBar.heightAnchor.constraint(equalToConstant: SuggestionBarView.barHeight)
        suggestionBarHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            suggestionBar.topAnchor.constraint(equalTo: self.view.topAnchor),
            suggestionBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            suggestionBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            heightConstraint
        ])
    }
    
    private func setupTouchEngine() {
        touchEngineView = KeyboardTouchEngineView()
        touchEngineView.delegate = self
        touchEngineView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.clipsToBounds = false
        self.view.addSubview(touchEngineView)
//        self.view.bringSubviewToFront(suggestionBar)
//        self.view.bringSubviewToFront(touchEngineView)
        
        NSLayoutConstraint.activate([
            touchEngineView.topAnchor.constraint(equalTo: suggestionBar.bottomAnchor, constant: -8),
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
    
    private var shouldShowSuggestionBar: Bool {
        return currentLayoutType == .letters
            && currentLanguage.hasSuggestions
            && KeyboardSettings.shared.enableSuggestions
    }
    
    private func refreshSuggestionBarVisibility() {
        let show = shouldShowSuggestionBar
        suggestionBar.isHidden = !show
        suggestionBarHeightConstraint?.constant = show ? SuggestionBarView.barHeight : 0
        if !show {
            suggestionBar.updateSuggestions([])
        }
    }
    
    func switchLayout(to type: KeyboardLayoutType, language: KeyboardLanguage? = nil) {
        if let lang = language { self.currentLanguage = lang }
        self.currentLayoutType = type
        
        if type == .emoji {
            showEmojiKeyboard()
            return
        }
        
        hideEmojiKeyboard()
        
        let key = cacheKey(for: currentLanguage, type: currentLayoutType)
        
        if let cachedLayout = layoutCache[key] {
            self.touchEngineView.applyLanguageLayout(cachedLayout)
        } else {
            prewarmLayouts(for: currentLanguage)
        }
        
        refreshSuggestionBarVisibility()
        if shouldShowSuggestionBar {
            updateSuggestions()
        }
    }
    
    // MARK: - Emoji Keyboard
    
    private func showEmojiKeyboard() {
        touchEngineView.isHidden = true
        suggestionBar.isHidden = true
        suggestionBarHeightConstraint?.constant = 0
        
        if emojiKeyboardView == nil {
            let emojiView = EmojiKeyboardView()
            emojiView.delegate = self
            emojiView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(emojiView)
            
            NSLayoutConstraint.activate([
                emojiView.topAnchor.constraint(equalTo: self.view.topAnchor),
                emojiView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                emojiView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                emojiView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
            
            emojiKeyboardView = emojiView
        }
        
        emojiKeyboardView?.isHidden = false
        emojiKeyboardView?.applyTheme()
    }
    
    private func hideEmojiKeyboard() {
        emojiKeyboardView?.isHidden = true
        touchEngineView.isHidden = false
    }
    
    func didSelectEmoji(_ emoji: String) {
        textDocumentProxy.insertText(emoji)
        EmojiRecentsManager.shared.recordUsage(emoji)
    }
    
    func didTapABCKey() {
        switchLayout(to: .letters)
    }
    
    func didTapBackspace() {
        textDocumentProxy.deleteBackward()
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
        if text == "emoji" { switchLayout(to: .emoji); return }
        
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
        if language.hasSuggestions {
            suggestionEngine.load(for: language)
        }
    }
    
    // MARK: - Suggestions
    
    private func updateSuggestions() {
        guard shouldShowSuggestionBar else {
            suggestionBar.updateSuggestions([])
            return
        }
        
        let prefix = currentPartialWord()
        if prefix.isEmpty {
            let context = textDocumentProxy.documentContextBeforeInput ?? ""
            if context.isEmpty {
                suggestionBar.updateSuggestions(suggestionEngine.starterSuggestions())
            } else {
                let lastWord = lastCompletedWord(in: context)
                if !lastWord.isEmpty {
                    let nextWords = suggestionEngine.nextWordSuggestions(after: lastWord, limit: 5)
                    suggestionBar.updateSuggestions(nextWords)
                } else {
                    suggestionBar.updateSuggestions([])
                }
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
    
    private func lastCompletedWord(in context: String) -> String {
        let trimmed = context.trimmingCharacters(in: .whitespacesAndNewlines)
        var word = ""
        for char in trimmed.reversed() {
            if char.isLetter || char == "'" || char == "\u{2019}" {
                word.append(char)
            } else {
                break
            }
        }
        return String(word.reversed()).lowercased()
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
