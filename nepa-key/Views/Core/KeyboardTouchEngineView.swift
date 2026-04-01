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
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTraitObservation()
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
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let key = findKey(at: location) {
            activeTouchTarget = key
            highlight(key: key, active: true)
            
            let specialKeyIDs = ["space", "return", "shift", "delete", "numbers", "letters", "symbols", "globe"]
            HapticEngine.shared.playTap(isSpecialKey: specialKeyIDs.contains(key.id))
            
            if KeyboardSettings.shared.enableSounds {
                UIDevice.current.playInputClick()
            }
            
            if key.id == "delete" {
                delegate?.deleteCharacter()
                startDeleteTimer()
            } else if !key.alternates.isEmpty {
                startLongPressTimer(for: key)
            }
        } else {
            print("Key Not Found at: ", location)
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
        
        if let keyToUnhighlight = activeTouchTarget {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.highlight(key: keyToUnhighlight, active: false)
            }
        }
        
        activeTouchTarget = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        longPressTimer?.invalidate()
        stopDeleteTimer()
        isShowingAlternates = false
        
        if let keyToUnhighlight = activeTouchTarget {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.highlight(key: keyToUnhighlight, active: false)
            }
        }
        
        activeTouchTarget = nil
        delegate?.hideAlternatesPopover()
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
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            
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
        self.activeKeys = layout.rows.flatMap { $0 }
        
        if keyBackgroundLayers.isEmpty {
            renderVisuals()
        } else {
            updateLayerFrames()
        }
    }
    
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        for key in activeKeys {
            guard let bgLayer = keyBackgroundLayers[key.id],
                  let label = keyLabels[key.id] else { continue }
            
            let visualFrame = key.frame.insetBy(dx: Metrics.keyVisualInset, dy: Metrics.keyVisualInset)
            
            bgLayer.path = UIBezierPath(roundedRect: visualFrame, cornerRadius: Metrics.keyCornerRadius).cgPath
            
            if let gradient = bgLayer.sublayers?.first(where: { $0 is CAGradientLayer }) {
                gradient.frame = bgLayer.path?.boundingBoxOfPath ?? bgLayer.bounds
            }
            
            label.frame = visualFrame
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
            
            // THE FIX: Check if this specific key is currently being pressed down
            let isActive = (key.id == activeTouchTarget?.id)
            
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
