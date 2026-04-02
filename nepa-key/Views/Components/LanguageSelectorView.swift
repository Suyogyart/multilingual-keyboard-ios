//
//  LanguageSelectorView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 01/04/26.
//

import UIKit

class LanguageSelectorView: UIView {
    private let options: [KeyboardLanguage]
    private let currentLanguage: KeyboardLanguage
    private let baseKeyFrame: CGRect
    private var highlightedIndex: Int = 0
    
    private let slotWidth: CGFloat = 180.0
    private let slotHeight: CGFloat = 44.0
    
    private var backgroundLayer = CAShapeLayer()
    private var highlightLayer = CAShapeLayer()
    private var textLabels: [UILabel] = []
    private var checkmarkLabels: [UILabel] = []
    
    init(options: [KeyboardLanguage], currentLanguage: KeyboardLanguage, baseKeyFrame: CGRect, keyboardBounds: CGRect) {
        self.options = options
        self.currentLanguage = currentLanguage
        self.baseKeyFrame = baseKeyFrame
        
        if let idx = options.firstIndex(of: currentLanguage) {
            self.highlightedIndex = idx
        }
        
        let totalWidth = slotWidth
        let totalHeight = CGFloat(options.count) * slotHeight
        
        var xPos = baseKeyFrame.midX - (totalWidth / 2.0)
        var yPos = baseKeyFrame.minY - totalHeight - 12
        
        let topPadding: CGFloat = 5.0
        if yPos < keyboardBounds.minY + topPadding {
            yPos = keyboardBounds.minY + topPadding
        }
        
        let sidePadding: CGFloat = 5.0
        if xPos < keyboardBounds.minX + sidePadding {
            xPos = keyboardBounds.minX + sidePadding
        } else if xPos + totalWidth > keyboardBounds.maxX - sidePadding {
            xPos = keyboardBounds.maxX - totalWidth - sidePadding
        }
        
        super.init(frame: CGRect(x: xPos, y: yPos, width: totalWidth, height: totalHeight))
        
        setupTraitObservation()
        setupVisuals()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Trait Observation
    
    private func setupTraitObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: LanguageSelectorView, _) in
                view.updateTheme()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateTheme()
            }
        }
    }
    
    private func updateTheme() {
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        backgroundLayer.fillColor = colors.keyboardBackground.cgColor
        backgroundLayer.shadowColor = colors.shadowColor.cgColor
        
        backgroundLayer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        if let gradColors = colors.gradientColors {
            let gradient = CAGradientLayer()
            gradient.frame = backgroundLayer.path?.boundingBoxOfPath ?? backgroundLayer.bounds
            gradient.colors = gradColors.map { $0.cgColor }
            gradient.cornerRadius = 10.0
            
            if colors.isLiquidGlass {
                backgroundLayer.borderWidth = 0.5
                backgroundLayer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
            } else {
                backgroundLayer.borderWidth = 0
            }
            backgroundLayer.insertSublayer(gradient, at: 0)
        } else {
            backgroundLayer.fillColor = colors.keyBackground.cgColor
            backgroundLayer.borderWidth = 0
        }
        
        for (index, label) in textLabels.enumerated() {
            if index == highlightedIndex {
                label.textColor = colors.isLiquidGlass ? .white : colors.specialKeyBackground
            } else {
                label.textColor = colors.textColor
            }
        }
        
        for (index, check) in checkmarkLabels.enumerated() {
            check.isHidden = (options[index] != currentLanguage)
            check.textColor = colors.textColor
        }
        
        highlightLayer.fillColor = colors.textColor.withAlphaComponent(0.2).cgColor
        
        CATransaction.commit()
    }
    
    // MARK: - Visual Setup
    
    private func setupVisuals() {
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10.0).cgPath
        backgroundLayer.shadowOpacity = 0.3
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 4.0)
        backgroundLayer.shadowRadius = 8.0
        self.layer.addSublayer(backgroundLayer)
        
        self.layer.addSublayer(highlightLayer)
        
        for (index, language) in options.enumerated() {
            let rowFrame = CGRect(x: 0, y: CGFloat(index) * slotHeight, width: slotWidth, height: slotHeight)
            
            let label = UILabel(frame: rowFrame.insetBy(dx: 12, dy: 0))
            label.text = language.displayName
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .left
            self.addSubview(label)
            textLabels.append(label)
            
            let checkSize: CGFloat = 20
            let checkFrame = CGRect(
                x: slotWidth - checkSize - 12,
                y: rowFrame.midY - checkSize / 2,
                width: checkSize,
                height: checkSize
            )
            let check = UILabel(frame: checkFrame)
            check.text = "✓"
            check.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            check.textAlignment = .center
            check.isHidden = (language != currentLanguage)
            self.addSubview(check)
            checkmarkLabels.append(check)
        }
        
        updateTheme()
        updateHighlight(to: highlightedIndex)
    }
    
    // MARK: - Interaction
    
    func handlePan(touchPointInKeyboard: CGPoint) {
        let localPoint = self.convert(touchPointInKeyboard, from: self.superview)
        
        var row = Int(localPoint.y / slotHeight)
        row = max(0, min(row, options.count - 1))
        
        updateHighlight(to: row)
    }
    
    private func updateHighlight(to index: Int) {
        guard index >= 0, index < options.count else { return }
        
        let colors = ThemeManager.current(traitCollection: self.traitCollection)
        let oldIndex = highlightedIndex
        highlightedIndex = index
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if oldIndex < textLabels.count {
            textLabels[oldIndex].textColor = colors.textColor
        }
        
        textLabels[highlightedIndex].textColor = colors.isLiquidGlass ? .white : colors.specialKeyBackground
        
        let highlightRect = CGRect(
            x: 0,
            y: CGFloat(index) * slotHeight,
            width: slotWidth,
            height: slotHeight
        ).insetBy(dx: 4, dy: 3)
        
        highlightLayer.path = UIBezierPath(roundedRect: highlightRect, cornerRadius: 8.0).cgPath
        highlightLayer.fillColor = colors.textColor.withAlphaComponent(0.2).cgColor
        
        CATransaction.commit()
    }
    
    func getSelectedLanguage() -> KeyboardLanguage? {
        guard highlightedIndex >= 0, highlightedIndex < options.count else { return nil }
        return options[highlightedIndex]
    }
}
