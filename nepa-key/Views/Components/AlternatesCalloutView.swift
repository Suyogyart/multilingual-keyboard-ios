//
//  AlternatesCalloutView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

class AlternatesCalloutView: UIView {
    private let alternates: [String]
    private let baseKeyFrame: CGRect
    private var highlightedIndex: Int = 0
    
    // Grid Math
    private let maxColumns = 5
    private let columns: Int
    private let rows: Int
    private let slotWidth: CGFloat = 42.0
    private let slotHeight: CGFloat = 48.0
    
    // Visual Layers
    private var backgroundLayer = CAShapeLayer()
    private var highlightLayer = CAShapeLayer()
    private var textLabels: [UILabel] = []
    
    init(alternates: [String], baseKeyFrame: CGRect, keyboardBounds: CGRect) {
        self.alternates = alternates
        self.baseKeyFrame = baseKeyFrame
        
        // 1. Calculate the Grid Dimensions
        self.columns = min(alternates.count, maxColumns)
        self.rows = Int(ceil(Double(alternates.count) / Double(columns)))
        
        let totalWidth = CGFloat(columns) * slotWidth
        let totalHeight = CGFloat(rows) * slotHeight
        
        // 2. Calculate Ideal Position (Centered above the base key)
        var xPos = baseKeyFrame.midX - (totalWidth / 2.0)
        var yPos = baseKeyFrame.minY - totalHeight - 12 // 12pt gap above the key
        
        // 3. Smart Bounds Checking (Prevent clipping off-screen)
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
    
    // MARK: - Dark/Light Mode Handling
    
    private func setupTraitObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: AlternatesCalloutView, _) in
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
        let colors = ThemeManager.current()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Update background
        backgroundLayer.fillColor = colors.keyboardBackground.cgColor
        backgroundLayer.shadowColor = colors.shadowColor.cgColor
        
        // Handle Gradients / Liquid Glass in bubble
        backgroundLayer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        if let gradColors = colors.gradientColors {
            let gradient = CAGradientLayer()
            gradient.frame = backgroundLayer.path?.boundingBoxOfPath ?? backgroundLayer.bounds
            gradient.colors = gradColors.map { $0.cgColor }
            gradient.cornerRadius = 8.0
            
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
        
        // Update Labels
        for (index, label) in textLabels.enumerated() {
            if index == highlightedIndex {
                label.textColor = colors.isLiquidGlass ? .white : colors.specialKeyBackground
            } else {
                label.textColor = colors.textColor
            }
        }
        
        // Update Highlight color
        highlightLayer.fillColor = colors.textColor.withAlphaComponent(0.2).cgColor
        
        CATransaction.commit()
    }
    
    // MARK: - Visual Setup
    
    private func setupVisuals() {
        // 1. Draw the Main Bubble Background
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8.0).cgPath
        
        backgroundLayer.shadowOpacity = 0.3
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 4.0)
        backgroundLayer.shadowRadius = 8.0
        self.layer.addSublayer(backgroundLayer)
        
        // 2. Draw the Highlight Layer
        self.layer.addSublayer(highlightLayer)
        
        // 3. Draw the Grid of Labels
        for (index, altChar) in alternates.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let charFrame = CGRect(x: CGFloat(col) * slotWidth,
                                   y: CGFloat(row) * slotHeight,
                                   width: slotWidth,
                                   height: slotHeight)
            
            let label = UILabel(frame: charFrame)
            label.text = altChar
            label.font = UIFont.systemFont(ofSize: 22, weight: .regular)
            label.textAlignment = .center
            
            self.addSubview(label)
            textLabels.append(label)
        }
        
        // Initial theme application
        updateTheme()
        
        // Highlight the default first item
        updateHighlight(to: 0)
    }
    
    // MARK: - Interaction
    
    func handlePan(touchPointInKeyboard: CGPoint) {
        let localPoint = self.convert(touchPointInKeyboard, from: self.superview)
        
        var col = Int(localPoint.x / slotWidth)
        var row = Int(localPoint.y / slotHeight)
        
        col = max(0, min(col, columns - 1))
        row = max(0, min(row, rows - 1))
        
        var newIndex = (row * columns) + col
        
        if newIndex >= alternates.count {
            newIndex = alternates.count - 1
        }
        
        updateHighlight(to: newIndex)
    }
    
    private func updateHighlight(to index: Int) {
        guard index >= 0, index < alternates.count else { return }
        
        let colors = ThemeManager.current()
        let oldIndex = highlightedIndex
        highlightedIndex = index
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Revert old label
        if oldIndex < textLabels.count {
            textLabels[oldIndex].textColor = colors.textColor
        }
        
        // Highlight new label
        textLabels[highlightedIndex].textColor = colors.isLiquidGlass ? .white : colors.specialKeyBackground
        
        // Move the highlight rectangle
        let row = index / columns
        let col = index % columns
        let highlightRect = CGRect(x: CGFloat(col) * slotWidth,
                                   y: CGFloat(row) * slotHeight,
                                   width: slotWidth,
                                   height: slotHeight).insetBy(dx: 4, dy: 4)
        
        highlightLayer.path = UIBezierPath(roundedRect: highlightRect, cornerRadius: 6.0).cgPath
        highlightLayer.fillColor = colors.textColor.withAlphaComponent(0.2).cgColor
        
        CATransaction.commit()
    }
    
    func getSelectedCharacter() -> String? {
        guard highlightedIndex >= 0 && highlightedIndex < alternates.count else { return nil }
        return alternates[highlightedIndex]
    }
}
