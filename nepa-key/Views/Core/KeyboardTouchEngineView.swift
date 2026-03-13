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
    
    // The injected language layout
    var currentLayout: KeyboardLayout?
    
    func applyLanguageLayout(_ layout: KeyboardLayout) {
        self.currentLayout = layout
        self.setNeedsLayout()
    }
    
    var currentShiftState: ShiftState = .lowercased {
        didSet { renderVisuals() }
    }
    
    // Backspace State
    private var deleteTimer: Timer?
    private var deleteHoldDuration: TimeInterval = 0.0
    
    // State tracking for the touch engine
    private var activeTouchTarget: KeyModel?
    private var longPressTimer: Timer?
    private var isShowingAlternates = false
    private var keyBackgroundLayers: [String: CAShapeLayer] = [:]
    
    weak var delegate: KeyboardEngineDelegate?
    
    // MARK: - Init & Traits
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTraitObservation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTraitObservation()
    }
    
    private func setupTraitObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: KeyboardTouchEngineView, previousTrait) in
                view.renderVisuals()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                renderVisuals()
            }
        }
    }
    
    // MARK: - Layout Math
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard var layout = currentLayout, bounds.width > 0 else { return }
        
        let horizontalSpacing: CGFloat = 2.0
        let verticalSpacing: CGFloat = 8.0
        let edgeInsets = UIEdgeInsets(top: 12, left: 4, bottom: 8, right: 4)
        
        let rowCount = CGFloat(layout.rows.count)
        let totalVerticalSpacing = (rowCount - 1) * verticalSpacing
        let availableHeight = bounds.height - edgeInsets.top - edgeInsets.bottom - totalVerticalSpacing
        let rowHeight = availableHeight / rowCount
        
        var currentY = edgeInsets.top
        
        for rowIndex in 0..<layout.rows.count {
            let keysInRow = layout.rows[rowIndex]
            let keyCount = CGFloat(keysInRow.count)
            let totalMultipliers = keysInRow.reduce(0) { $0 + $1.widthMultiplier }
            let totalHorizontalSpacing = (keyCount - 1) * horizontalSpacing
            let availableWidth = bounds.width - edgeInsets.left - edgeInsets.right - totalHorizontalSpacing
            let baseUnitWidth = availableWidth / totalMultipliers
            
            var currentX = edgeInsets.left
            
            for keyIndex in 0..<keysInRow.count {
                let key = keysInRow[keyIndex]
                let keyWidth = baseUnitWidth * key.widthMultiplier
                let keyFrame = CGRect(x: currentX, y: currentY, width: keyWidth, height: rowHeight)
                layout.rows[rowIndex][keyIndex].frame = keyFrame
                currentX += keyWidth + horizontalSpacing
            }
            currentY += rowHeight + verticalSpacing
        }
        
        self.currentLayout = layout
        renderVisuals()
    }
    
    // MARK: - Touch Routing
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let key = findKey(at: location) {
            activeTouchTarget = key
            highlight(key: key, active: true)
            
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
            if let newKey = findKey(at: location) {
                if newKey.id != key.id {
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
                
                // 1. Define all keys that should send their ID instead of their Label
                let controlKeys = ["space", "return", "shift", "globe", "numbers", "letters", "symbols"]
                
                if controlKeys.contains(key.id) {
                    // Send the command ID (e.g., "numbers") to the controller
                    delegate?.insertCharacter(key.id)
                } else {
                    // Send the actual text to be typed
                    let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
                    let textToInsert = (isShifted && key.shiftLabel != nil) ? key.shiftLabel! : key.primaryLabel
                    delegate?.insertCharacter(textToInsert)
                }
            }
        }
        
        if let key = activeTouchTarget {
            highlight(key: key, active: false)
        }
        activeTouchTarget = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        stopDeleteTimer()
        isShowingAlternates = false
        activeTouchTarget = nil
        delegate?.hideAlternatesPopover()
    }
    
    // MARK: - Helpers
    private func findKey(at point: CGPoint) -> KeyModel? {
        guard let layout = currentLayout else { return nil }
        
        if let exactKey = layout.rows.flatMap({ $0 }).first(where: { $0.frame.contains(point) }) {
            return exactKey
        }
        
        var closestKey: KeyModel?
        var shortestDistance: CGFloat = .greatestFiniteMagnitude
        
        for row in layout.rows {
            for key in row {
                let centerX = key.frame.midX
                let centerY = key.frame.midY
                let distance = hypot(point.x - centerX, point.y - centerY)
                
                if distance < shortestDistance {
                    shortestDistance = distance
                    closestKey = key
                }
            }
        }
        return closestKey
    }
    
    private func startLongPressTimer(for key: KeyModel) {
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.isShowingAlternates = true
            self?.delegate?.showAlternatesPopover(for: key)
        }
    }
    
    private func startDeleteTimer() {
        deleteHoldDuration = 0.0
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.deleteHoldDuration += 0.1
            
            if self.deleteHoldDuration < 0.4 { return }
            
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

// MARK: - Visual Rendering Extension
extension KeyboardTouchEngineView {
    
    func renderVisuals() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.keyBackgroundLayers.removeAll()
        
        guard let layout = currentLayout else { return }
        for row in layout.rows {
            for key in row {
                drawKey(keyModel: key)
            }
        }
    }
    
    private func drawKey(keyModel: KeyModel) {
        let backgroundLayer = CAShapeLayer()
        let visualInset: CGFloat = 3.0
        let visualFrame = keyModel.frame.insetBy(dx: visualInset, dy: visualInset)
        
        backgroundLayer.path = UIBezierPath(roundedRect: visualFrame, cornerRadius: 5.0).cgPath
        
        let isDark = KeyboardTheme.isDark(traitCollection: self.traitCollection)
        let isSpecial = keyModel.isAction ?? false
        
        let isShifted = currentShiftState == .uppercased || currentShiftState == .capsLocked
        let isShiftKeyActive = keyModel.id == "shift" && isShifted
        
        // If it's the active shift key, force the background to stay in the 'pressed' color
        if isShiftKeyActive {
            backgroundLayer.fillColor = KeyboardTheme.pressedKeyColor(isSpecial: isSpecial, isDark: isDark)
        } else {
            backgroundLayer.fillColor = KeyboardTheme.keyColor(isSpecial: isSpecial, isDark: isDark)
        }
        
        backgroundLayer.shadowColor = KeyboardTheme.shadowColor(isDark: isDark)
        backgroundLayer.shadowOpacity = 1.0
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 1.0)
        backgroundLayer.shadowRadius = 0.0
        
        self.layer.addSublayer(backgroundLayer)
        keyBackgroundLayers[keyModel.id] = backgroundLayer
        
        let textLayer = CATextLayer()
        
        // Dynamic Text Rendering for Shift States
        var displayText = keyModel.primaryLabel
        
        if keyModel.id == "shift" {
            displayText = isShifted ? "⇪" : "⇧"
        } else if isShifted, let shiftChar = keyModel.shiftLabel {
            displayText = shiftChar
        } else if isShifted && keyModel.primaryLabel.count == 1 {
            // Fallback for English if shiftLabel isn't provided in JSON
            displayText = keyModel.primaryLabel.uppercased()
        }
        
        // Use the JSON font size if it exists, otherwise default to 22
        let calculatedFontSize = keyModel.fontSize ?? 22.0
        
        // Create the UIFont object first so we can measure it
        let keyFont = UIFont.systemFont(ofSize: calculatedFontSize, weight: .regular)
        
        textLayer.string = displayText
        textLayer.font = keyFont
        textLayer.fontSize = calculatedFontSize
        textLayer.foregroundColor = KeyboardTheme.textColor(isDark: isDark)
        textLayer.alignmentMode = .center
        textLayer.contentsScale = self.traitCollection.displayScale
        
        // 2. Ask the font exactly how tall it is
        let textHeight = keyFont.lineHeight
        
        // 3. Center that exact height inside the physical key's visual frame
        let textY = visualFrame.origin.y + (visualFrame.height - textHeight) / 2.0
        
        textLayer.frame = CGRect(x: visualFrame.origin.x, y: textY, width: visualFrame.width, height: textHeight)
        
        self.layer.addSublayer(textLayer)
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
}
