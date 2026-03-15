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
    private var activeTouchTarget: KeyModel?
    private var isShowingAlternates = false
    private var keyBackgroundLayers: [String: CAShapeLayer] = [:]
    private var keyLabels: [String: UILabel] = [:]
    private var activeKeys: [KeyModel] = []
    
    // MARK: Properties (Timers)
    private var longPressTimer: Timer?
    private var deleteTimer: Timer?
    private var deleteHoldDuration: TimeInterval = 0.0
    
    // MARK: - Init & Traits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTraitObservation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTraitObservation()
    }
    
    func applyLanguageLayout(_ layout: KeyboardLayout) {
        self.currentLayout = layout
        
        // CRITICAL FIX: Wipe the board clean when layouts change.
        // This forces layoutSubviews to draw fresh layers (e.g., when switching to Numbers)
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.keyBackgroundLayers.removeAll()
        self.keyLabels.removeAll()
        self.activeKeys.removeAll()
        
        self.setNeedsLayout() // Triggers layoutSubviews()
    }
    
    private func setupTraitObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: KeyboardTouchEngineView, _) in
                view.renderVisuals()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // We only need manual observation for iOS 16 and below.
        // iOS 17+ is already handled by setupTraitObservation() in the init.
        if #unavailable(iOS 17.0) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                renderVisuals()
            }
        }
    }
}

// MARK: - Touch Handling
extension KeyboardTouchEngineView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let key = findKey(at: location) {
            activeTouchTarget = key
            highlight(key: key, active: true)
            
            // Play Haptics
            let specialKeyIDs = ["space", "return", "shift", "delete", "numbers", "letters", "symbols", "globe"]
            HapticEngine.shared.playTap(isSpecialKey: specialKeyIDs.contains(key.id))
            
            // Play Sounds only if enabled
            if KeyboardSettings.shared.enableSounds {
                UIDevice.current.playInputClick()
            }
            
            if key.id == "delete" {
                delegate?.deleteCharacter()
                startDeleteTimer()
            } else if !key.alternates.isEmpty {
                startLongPressTimer(for: key)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let key = activeTouchTarget else { return }
        let location = touch.location(in: self)
        
        if isShowingAlternates {
            delegate?.handleSlideOverAlternates(at: location)
        } else {
            if let newKey = findKey(at: location), newKey.id != key.id {
                longPressTimer?.invalidate()
                stopDeleteTimer()
                
                highlight(key: key, active: false)
                activeTouchTarget = newKey
                highlight(key: newKey, active: true)
                
                if !newKey.alternates.isEmpty && newKey.id != "delete" {
                    startLongPressTimer(for: newKey)
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        stopDeleteTimer()
        
        if isShowingAlternates {
            delegate?.insertSelectedAlternateCharacter()
            delegate?.hideAlternatesPopover()
            isShowingAlternates = false
        } else if let key = activeTouchTarget {
            if key.id != "delete" {
                let controlKeys = ["space", "return", "shift", "globe", "numbers", "letters", "symbols"]
                
                if controlKeys.contains(key.id) {
                    delegate?.insertCharacter(key.id)
                } else {
                    let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
                    let textToInsert = (isShifted && key.shiftLabel != nil) ? key.shiftLabel! : key.primaryLabel
                    delegate?.insertCharacter(textToInsert)
                }
            }
        }
        
        // --- THE EDGE-TAP FIX ---
        if let keyToUnhighlight = activeTouchTarget {
            // Delay the turn-off by 50ms (3 frames). This forces the GPU to
            // draw the 'pressed' state even when iOS clumps edge touches together.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.highlight(key: keyToUnhighlight, active: false)
            }
        }
        // ------------------------
        
        activeTouchTarget = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        stopDeleteTimer()
        isShowingAlternates = false
        
        // --- THE EDGE-TAP FIX ---
        if let keyToUnhighlight = activeTouchTarget {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.highlight(key: keyToUnhighlight, active: false)
            }
        }
        // ------------------------
        
        activeTouchTarget = nil
        delegate?.hideAlternatesPopover()
    }
}

// MARK: - Action Helpers
extension KeyboardTouchEngineView {
    
    private func findKey(at point: CGPoint) -> KeyModel? {
        // 1. Exact Hit Test (Now completely flat)
        if let exactKey = activeKeys.first(where: { $0.frame.contains(point) }) {
            return exactKey
        }
        
        // 2. Dead-Zone Pythagorean Fallback
        var closestKey: KeyModel?
        var shortestDistance: CGFloat = .greatestFiniteMagnitude
        
        for key in activeKeys {
            let centerX = key.frame.midX
            let centerY = key.frame.midY
            let distance = hypot(point.x - centerX, point.y - centerY)
            
            if distance < shortestDistance {
                shortestDistance = distance
                closestKey = key
            }
        }
        return closestKey
    }
    
    private func startLongPressTimer(for key: KeyModel) {
        longPressTimer?.invalidate()
        
        let delay = KeyboardSettings.shared.longPressDelay
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            
            // Trigger haptic feedback when the popup appears to let the user know
            if KeyboardSettings.shared.enableHaptics {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
            
            self?.isShowingAlternates = true
            self?.delegate?.showAlternatesPopover(for: key)
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
        
        // 1. BOUNDS BOUNCE GUARD:
        // Ignore height=0 (collapsed) and height>400 (iOS full-screen initialization glitch).
        guard var layout = currentLayout, bounds.width > 0, bounds.height > 0, bounds.height < 400 else { return }
        
        let rowCount = CGFloat(layout.rows.count)
        let totalVerticalSpacing = (rowCount - 1) * Metrics.verticalSpacing
        let availableHeight = bounds.height - Metrics.edgeInsets.top - Metrics.edgeInsets.bottom - totalVerticalSpacing
        let rowHeight = availableHeight / rowCount
        
        var currentY = Metrics.edgeInsets.top
        
        for rowIndex in 0..<layout.rows.count {
            let keysInRow = layout.rows[rowIndex]
            let keyCount = CGFloat(keysInRow.count)
            let totalMultipliers = keysInRow.reduce(0) { $0 + $1.widthMultiplier }
            let totalHorizontalSpacing = (keyCount - 1) * Metrics.horizontalSpacing
            let availableWidth = bounds.width - Metrics.edgeInsets.left - Metrics.edgeInsets.right - totalHorizontalSpacing
            let baseUnitWidth = availableWidth / totalMultipliers
            
            var currentX = Metrics.edgeInsets.left
            
            for keyIndex in 0..<keysInRow.count {
                let key = keysInRow[keyIndex]
                let keyWidth = baseUnitWidth * key.widthMultiplier
                let keyFrame = CGRect(x: currentX, y: currentY, width: keyWidth, height: rowHeight)
                layout.rows[rowIndex][keyIndex].frame = keyFrame
                currentX += keyWidth + Metrics.horizontalSpacing
            }
            currentY += rowHeight + Metrics.verticalSpacing
        }
        
        self.currentLayout = layout
        
        // Update the flattened array with the newly calculated frames for accurate hit-testing
        self.activeKeys = layout.rows.flatMap { $0 }
        
        // 2. PERFORMANCE FIX: Mutative Rendering
        if keyBackgroundLayers.isEmpty {
            renderVisuals()
        } else {
            updateLayerFrames()
        }
    }
    
    // Smoothly resizes existing layers (crucial for zero-lag layout updates and rotation)
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for key in activeKeys {
            guard let bgLayer = keyBackgroundLayers[key.id],
                  let label = keyLabels[key.id] else { continue } // UPDATED
            
            let visualFrame = key.frame.insetBy(dx: Metrics.keyVisualInset, dy: Metrics.keyVisualInset)
            
            // Instantly update background size
            bgLayer.path = UIBezierPath(roundedRect: visualFrame, cornerRadius: Metrics.keyCornerRadius).cgPath
            
            // Instantly update label frame
            label.frame = visualFrame // UPDATED
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
        let visualFrame = keyModel.frame.insetBy(dx: Metrics.keyVisualInset, dy: Metrics.keyVisualInset)
        
        backgroundLayer.path = UIBezierPath(roundedRect: visualFrame, cornerRadius: Metrics.keyCornerRadius).cgPath
        
        let isDark = KeyboardTheme.isDark(traitCollection: self.traitCollection)
        let isSpecial = keyModel.isAction ?? false
        let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
        
        backgroundLayer.fillColor = KeyboardTheme.keyColor(isSpecial: isSpecial, isDark: isDark)
        
        backgroundLayer.shadowColor = KeyboardTheme.shadowColor(isDark: isDark)
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
        label.textColor = UIColor(cgColor: KeyboardTheme.textColor(isDark: isDark))
        label.textAlignment = .center
        label.frame = visualFrame // UILabel vertically centers automatically!
        
        self.addSubview(label)
        keyLabels[keyModel.id] = label
    }

    private func highlight(key: KeyModel, active: Bool) {
        guard let layer = keyBackgroundLayers[key.id] else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let isDark = KeyboardTheme.isDark(traitCollection: self.traitCollection)
        let isSpecial = key.isAction ?? false
        
        if active {
            layer.fillColor = KeyboardTheme.pressedKeyColor(isSpecial: isSpecial, isDark: isDark)
        } else {
            layer.fillColor = KeyboardTheme.keyColor(isSpecial: isSpecial, isDark: isDark)
        }
        
        CATransaction.commit()
    }
    
    private func updateKeyVisualsForShiftState() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
        
        for key in activeKeys {
            // UPDATED: Check keyLabels instead of keyTextLayers
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
                
                label.text = displayText // UPDATED
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
        let colors = ThemeManager.current()
        self.backgroundColor = colors.keyboardBackground
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for key in activeKeys {
            if let bgLayer = keyBackgroundLayers[key.id], let label = keyLabels[key.id] {
                let isSpecial = key.isAction ?? false
                bgLayer.fillColor = isSpecial ? colors.specialKeyBackground.cgColor : colors.keyBackground.cgColor
                bgLayer.shadowColor = colors.shadowColor.cgColor
                label.textColor = colors.textColor
            }
        }
        
        CATransaction.commit()
    }
}
