//
//  KeyboardTouchEngineView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

// MARK: - Delegate Protocol
protocol KeyboardEngineDelegate: AnyObject {
    func insertCharacter(_ text: String)
    func deleteCharacter()
    func showAlternatesPopover(for key: KeyModel)
    func hideAlternatesPopover()
    func handleSlideOverAlternates(at point: CGPoint)
    func insertSelectedAlternateCharacter()
    
    func switchToNextLanguage()
    func showLanguageSelector(for key: KeyModel)
    func hideLanguageSelector()
    func handleSlideOverLanguages(at point: CGPoint)
    func selectHighlightedLanguage()
}

// MARK: - Main View
class KeyboardTouchEngineView: UIView {
    
    // MARK: Metrics & Constants
    private enum Metrics {
        static let horizontalSpacing: CGFloat = 2.0
        static let verticalSpacing: CGFloat = 4.0
        static let edgeInsets = UIEdgeInsets(top: 12, left: 4, bottom: 8, right: 4)
        static let keyVisualInset: CGFloat = 2.0
        static let keyCornerRadius: CGFloat = 5.0
    }
    
    // MARK: Properties (Injected)
    weak var delegate: KeyboardEngineDelegate?
    
    var currentLayout: KeyboardLayout?
    var currentShiftState: ShiftState = .lowercased {
        didSet {
            if oldValue != currentShiftState {
                updateKeyVisualsForShiftState()
            }
        }
    }
    
    // MARK: Properties (Internal State)
    private var activeTouches: [UITouch: KeyModel] = [:]
    private var isShowingAlternates = false
    private var alternatesOwnerTouch: UITouch?
    private var isShowingLanguageSelector = false
    private var languageSelectorOwnerTouch: UITouch?
    private var keyBackgroundLayers: [String: CAShapeLayer] = [:]
    private var keyLabels: [String: UILabel] = [:]
    private var activeKeys: [KeyModel] = []
    
    // MARK: Properties (Timers)
    private var longPressTimer: Timer?
    private var longPressTouch: UITouch?
    private var deleteTimer: Timer?
    private var deleteTouch: UITouch?
    private var deleteHoldDuration: TimeInterval = 0.0
    
    // MARK: - Init & Traits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTraitObservation()
        self.isMultipleTouchEnabled = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTraitObservation()
        self.isMultipleTouchEnabled = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
    }
    
    func applyLanguageLayout(_ layout: KeyboardLayout) {
        self.currentLayout = layout
        
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.keyBackgroundLayers.removeAll()
        self.keyLabels.removeAll()
        self.activeKeys.removeAll()
        
        self.setNeedsLayout()
    }
    
    // THE FIX: Do not nuke layers on appearance change. Just update colors.
    private func setupTraitObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: KeyboardTouchEngineView, _) in
                view.applyTheme()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #unavailable(iOS 17.0) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
}

// MARK: - Touch Handling
extension KeyboardTouchEngineView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            guard let key = findKey(at: location) else { continue }
            
            activeTouches[touch] = key
            highlight(key: key, active: true)
            
            let specialKeyIDs = ["space", "return", "shift", "delete", "numbers", "letters", "symbols", "globe"]
            HapticEngine.shared.playTap(isSpecialKey: specialKeyIDs.contains(key.id))
            
            if KeyboardSettings.shared.enableSounds {
                UIDevice.current.playInputClick()
            }
            
            if key.id == "delete" {
                delegate?.deleteCharacter()
                deleteTouch = touch
                startDeleteTimer()
            } else if key.id == "globe" {
                longPressTouch = touch
                startGlobeLongPressTimer(for: key)
            } else if !key.alternates.isEmpty {
                longPressTouch = touch
                startLongPressTimer(for: key)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            guard let currentKey = activeTouches[touch] else { continue }
            let location = touch.location(in: self)
            
            if isShowingLanguageSelector && touch == languageSelectorOwnerTouch {
                delegate?.handleSlideOverLanguages(at: location)
            } else if isShowingAlternates && touch == alternatesOwnerTouch {
                delegate?.handleSlideOverAlternates(at: location)
            } else {
                let isPopoverTouch = (isShowingAlternates && touch == alternatesOwnerTouch)
                    || (isShowingLanguageSelector && touch == languageSelectorOwnerTouch)
                if isPopoverTouch { continue }
                
                if let newKey = findKey(at: location), newKey.id != currentKey.id {
                    if touch == longPressTouch {
                        longPressTimer?.invalidate()
                        longPressTouch = nil
                    }
                    if touch == deleteTouch {
                        stopDeleteTimer()
                    }
                    
                    highlight(key: currentKey, active: false)
                    activeTouches[touch] = newKey
                    highlight(key: newKey, active: true)
                    
                    if newKey.id == "globe" {
                        longPressTouch = touch
                        startGlobeLongPressTimer(for: newKey)
                    } else if !newKey.alternates.isEmpty && newKey.id != "delete" {
                        longPressTouch = touch
                        startLongPressTimer(for: newKey)
                    }
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == longPressTouch {
                longPressTimer?.invalidate()
                longPressTouch = nil
            }
            if touch == deleteTouch {
                stopDeleteTimer()
                deleteTouch = nil
            }
            
            if isShowingLanguageSelector && touch == languageSelectorOwnerTouch {
                delegate?.selectHighlightedLanguage()
                delegate?.hideLanguageSelector()
                isShowingLanguageSelector = false
                languageSelectorOwnerTouch = nil
            } else if isShowingAlternates && touch == alternatesOwnerTouch {
                delegate?.insertSelectedAlternateCharacter()
                delegate?.hideAlternatesPopover()
                isShowingAlternates = false
                alternatesOwnerTouch = nil
            } else if let key = activeTouches[touch] {
                if key.id == "globe" {
                    delegate?.switchToNextLanguage()
                } else if key.id != "delete" {
                    let controlKeys = ["space", "return", "shift", "numbers", "letters", "symbols"]
                    
                    if controlKeys.contains(key.id) {
                        delegate?.insertCharacter(key.id)
                    } else {
                        let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
                        let textToInsert = (isShifted && key.shiftLabel != nil) ? key.shiftLabel! : key.primaryLabel
                        delegate?.insertCharacter(textToInsert)
                    }
                }
            }
            
            if let keyToUnhighlight = activeTouches.removeValue(forKey: touch) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.highlight(key: keyToUnhighlight, active: false)
                }
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == longPressTouch {
                longPressTimer?.invalidate()
                longPressTouch = nil
            }
            if touch == deleteTouch {
                stopDeleteTimer()
                deleteTouch = nil
            }
            if touch == alternatesOwnerTouch {
                isShowingAlternates = false
                alternatesOwnerTouch = nil
                delegate?.hideAlternatesPopover()
            }
            if touch == languageSelectorOwnerTouch {
                isShowingLanguageSelector = false
                languageSelectorOwnerTouch = nil
                delegate?.hideLanguageSelector()
            }
            
            if let keyToUnhighlight = activeTouches.removeValue(forKey: touch) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.highlight(key: keyToUnhighlight, active: false)
                }
            }
        }
    }
}

// MARK: - Action Helpers
extension KeyboardTouchEngineView {
    
    private func findKey(at point: CGPoint) -> KeyModel? {
        if let exactKey = activeKeys.first(where: { $0.frame.contains(point) }) {
            return exactKey
        }
        
        return activeKeys.min(by: { key1, key2 in
            let dist1 = distanceSquared(from: point, to: key1.frame)
            let dist2 = distanceSquared(from: point, to: key2.frame)
            return dist1 < dist2
        })
    }
    
    private func distanceSquared(from point: CGPoint, to rect: CGRect) -> CGFloat {
        let dx = max(rect.minX - point.x, 0, point.x - rect.maxX)
        let dy = max(rect.minY - point.y, 0, point.y - rect.maxY)
        return dx * dx + dy * dy
    }
    
    private func startLongPressTimer(for key: KeyModel) {
        longPressTimer?.invalidate()
        
        let delay = KeyboardSettings.shared.longPressDelay
        let ownerTouch = longPressTouch
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            
            if KeyboardSettings.shared.enableHaptics {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
            
            self?.isShowingAlternates = true
            self?.alternatesOwnerTouch = ownerTouch
            self?.delegate?.showAlternatesPopover(for: key)
        }
    }
    
    private func startGlobeLongPressTimer(for key: KeyModel) {
        longPressTimer?.invalidate()
        
        let delay = KeyboardSettings.shared.longPressDelay
        let ownerTouch = longPressTouch
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            
            if KeyboardSettings.shared.enableHaptics {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
            
            self?.isShowingLanguageSelector = true
            self?.languageSelectorOwnerTouch = ownerTouch
            self?.delegate?.showLanguageSelector(for: key)
        }
    }
    
    private func startDeleteTimer() {
        deleteHoldDuration = 0.0
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.deleteHoldDuration += 0.1
            
            if self.deleteHoldDuration < 0.4 { return }
            
            HapticEngine.shared.playTap(isSpecialKey: false)
            UIDevice.current.playInputClick()
            
            self.delegate?.deleteCharacter()
            if self.deleteHoldDuration > 1.5 {
                self.delegate?.deleteCharacter()
                self.delegate?.deleteCharacter()
            }
        }
    }

    private func stopDeleteTimer() {
        deleteTimer?.invalidate()
        deleteTimer = nil
        deleteHoldDuration = 0.0
    }
}

// MARK: - Layout Math
extension KeyboardTouchEngineView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard var layout = currentLayout, bounds.width > 0, bounds.height > 0, bounds.height < 400 else { return }
        
        let rowCount = CGFloat(layout.rows.count)
        let availableHeight = bounds.height - Metrics.edgeInsets.top - Metrics.edgeInsets.bottom
        let rowHeight = availableHeight / rowCount
        
        var currentY = Metrics.edgeInsets.top
        
        for rowIndex in 0..<layout.rows.count {
            let keysInRow = layout.rows[rowIndex]
            let totalMultipliers = keysInRow.reduce(0) { $0 + $1.widthMultiplier }
            let availableWidth = bounds.width - Metrics.edgeInsets.left - Metrics.edgeInsets.right
            let baseUnitWidth = availableWidth / totalMultipliers
            
            var currentX = Metrics.edgeInsets.left
            
            for keyIndex in 0..<keysInRow.count {
                let key = keysInRow[keyIndex]
                let keyWidth = baseUnitWidth * key.widthMultiplier
                let keyFrame = CGRect(x: currentX, y: currentY, width: keyWidth, height: rowHeight)
                layout.rows[rowIndex][keyIndex].frame = keyFrame
                currentX += keyWidth
            }
            currentY += rowHeight
        }
        
        self.currentLayout = layout
        self.activeKeys = layout.rows.flatMap { $0 }
        
        if keyBackgroundLayers.isEmpty {
            renderVisuals()
        } else {
            updateLayerFrames()
        }
    }
    
    private func visualFrame(for key: KeyModel) -> CGRect {
        let dx = Metrics.keyVisualInset + Metrics.horizontalSpacing / 2.0
        let dy = Metrics.keyVisualInset + Metrics.verticalSpacing / 2.0
        return key.frame.insetBy(dx: dx, dy: dy)
    }
    
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for key in activeKeys {
            guard let bgLayer = keyBackgroundLayers[key.id],
                  let label = keyLabels[key.id] else { continue }
            
            let vFrame = visualFrame(for: key)
            
            bgLayer.path = UIBezierPath(roundedRect: vFrame, cornerRadius: Metrics.keyCornerRadius).cgPath
            
            if let gradient = bgLayer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                gradient.frame = bgLayer.path?.boundingBoxOfPath ?? bgLayer.bounds
            }
            
            label.frame = vFrame
        }
        
        CATransaction.commit()
    }
}

// MARK: - Visual Rendering
extension KeyboardTouchEngineView {
    
    func renderVisuals() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.keyLabels.values.forEach { $0.removeFromSuperview() }
        self.keyBackgroundLayers.removeAll()
        self.keyLabels.removeAll()
        self.activeKeys.removeAll()
        
        guard let layout = currentLayout else {
            CATransaction.commit()
            return
        }
        
        self.activeKeys = layout.rows.flatMap { $0 }
        
        for row in layout.rows {
            for key in row {
                drawKey(keyModel: key)
            }
        }
        
        applyTheme()
        
        CATransaction.commit()
    }
    
    private func drawKey(keyModel: KeyModel) {
        let backgroundLayer = CAShapeLayer()
        let visualFrame = self.visualFrame(for: keyModel)
        
        backgroundLayer.path = UIBezierPath(roundedRect: visualFrame, cornerRadius: Metrics.keyCornerRadius).cgPath
        
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        let isSpecial = keyModel.isAction ?? false
        let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
        
        // Let applyTheme handle the opacity, start with solid base
        let baseColor = isSpecial ? colors.specialKeyBackground : colors.keyBackground
        backgroundLayer.fillColor = baseColor.cgColor
        
        backgroundLayer.shadowColor = colors.shadowColor.cgColor
        backgroundLayer.shadowOpacity = 1.0
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 1.0)
        backgroundLayer.shadowRadius = 0.0
        
        self.layer.addSublayer(backgroundLayer)
        keyBackgroundLayers[keyModel.id] = backgroundLayer
        
        let label = UILabel()
        var displayText = keyModel.primaryLabel
        
        if keyModel.id == "shift" {
            if currentShiftState == .capsLocked || currentShiftState == .uppercased {
                displayText = "⇪"
            } else {
                displayText = "⇧"
            }
        } else if isShifted, let shiftChar = keyModel.shiftLabel {
            displayText = shiftChar
        } else if isShifted && keyModel.primaryLabel.count == 1 {
            displayText = keyModel.primaryLabel.uppercased()
        }
        
        let calculatedFontSize = keyModel.fontSize ?? 22.0
        
        label.text = displayText
        label.font = UIFont.systemFont(ofSize: calculatedFontSize, weight: .regular)
        label.textColor = colors.textColor
        label.textAlignment = .center
        label.frame = visualFrame
        
        self.addSubview(label)
        keyLabels[keyModel.id] = label
    }

    private func highlight(key: KeyModel, active: Bool) {
        guard let bgLayer = keyBackgroundLayers[key.id] else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        let isSpecial = key.isAction ?? false
        
        let gradientLayer = bgLayer.sublayers?.first(where: { $0 is CAGradientLayer })
        
        if active {
            if let grad = gradientLayer {
                grad.opacity = 0.6
            } else {
                let baseColor = isSpecial ? colors.specialKeyBackground : colors.keyBackground
                bgLayer.fillColor = baseColor.withAlphaComponent(0.5).cgColor
            }
        } else {
            if let grad = gradientLayer {
                grad.opacity = 1.0
            } else {
                bgLayer.fillColor = isSpecial ? colors.specialKeyBackground.cgColor : colors.keyBackground.cgColor
            }
        }
        
        CATransaction.commit()
    }
    
    private func updateKeyVisualsForShiftState() {
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
        
        for key in activeKeys {
            if let label = keyLabels[key.id] {
                var displayText = key.primaryLabel
                
                if key.id == "shift" {
                    if currentShiftState == .capsLocked || currentShiftState == .uppercased {
                        displayText = "⇪"
                    } else {
                        displayText = "⇧"
                    }
                } else if isShifted, let shiftChar = key.shiftLabel {
                    displayText = shiftChar
                } else if isShifted && key.primaryLabel.count == 1 {
                    displayText = key.primaryLabel.uppercased()
                }
                
                label.text = displayText
                label.textColor = colors.textColor
            }
            
            if key.id == "shift" {
                highlight(key: key, active: false)
            }
        }
        
        CATransaction.commit()
    }
}

extension KeyboardTouchEngineView {
    func applyTheme() {
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        self.overrideUserInterfaceStyle = colors.interfaceStyle
        self.backgroundColor = colors.keyboardBackground
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for key in activeKeys {
            guard let bgLayer = keyBackgroundLayers[key.id], let label = keyLabels[key.id] else { continue }
            
            let isActive = activeTouches.values.contains(where: { $0.id == key.id })
            
            bgLayer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            
            if let gradColors = colors.gradientColors {
                let gradient = CAGradientLayer()
                
                // THE FIX: bgLayer.bounds, not layer.bounds
                gradient.frame = bgLayer.path?.boundingBoxOfPath ?? bgLayer.bounds
                
                gradient.colors = gradColors.map { $0.cgColor }
                gradient.cornerRadius = Metrics.keyCornerRadius
                
                if colors.isLiquidGlass {
                    gradient.locations = [0.0, 0.5]
                    bgLayer.borderWidth = 0.5
                    bgLayer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
                }
                
                bgLayer.insertSublayer(gradient, at: 0)
                bgLayer.fillColor = UIColor.clear.cgColor
                
                // Retain the visual highlight state if pressed during theme change
                gradient.opacity = isActive ? 0.6 : 1.0
                
            } else {
                let baseColor = key.isAction == true ? colors.specialKeyBackground : colors.keyBackground
                
                // Retain the visual highlight state if pressed during theme change
                bgLayer.fillColor = isActive ? baseColor.withAlphaComponent(0.5).cgColor : baseColor.cgColor
                bgLayer.borderWidth = 0
            }
            
            label.textColor = colors.textColor
        }
        CATransaction.commit()
    }
}
