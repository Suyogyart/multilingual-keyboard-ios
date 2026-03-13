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
    private var textLayers: [CATextLayer] = []
    
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
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: AlternatesCalloutView, previousTrait) in
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
        let isDark = KeyboardTheme.isDark(traitCollection: self.traitCollection)
        
        // Match the background to standard keys, but elevated
        backgroundLayer.fillColor = KeyboardTheme.keyColor(isSpecial: false, isDark: isDark)
        backgroundLayer.shadowColor = KeyboardTheme.shadowColor(isDark: isDark)
        
        // Update all text layers
        let standardTextColor = KeyboardTheme.textColor(isDark: isDark)
        for (index, textLayer) in textLayers.enumerated() {
            // Keep the highlighted text white (since the highlight bubble is blue)
            textLayer.foregroundColor = (index == highlightedIndex) ? UIColor.white.cgColor : standardTextColor
        }
    }
    
    // MARK: - Visual Setup
    
    private func setupVisuals() {
        let isDark = KeyboardTheme.isDark(traitCollection: self.traitCollection)
        
        // 1. Draw the Main Bubble Background
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8.0).cgPath
        backgroundLayer.fillColor = KeyboardTheme.keyColor(isSpecial: false, isDark: isDark)
        
        backgroundLayer.shadowColor = KeyboardTheme.shadowColor(isDark: isDark)
        backgroundLayer.shadowOpacity = 0.3
        backgroundLayer.shadowOffset = CGSize(width: 0, height: 4.0)
        backgroundLayer.shadowRadius = 8.0
        self.layer.addSublayer(backgroundLayer)
        
        // 2. Draw the Blue Highlight Layer (Hidden initially, or set to index 0)
        highlightLayer.fillColor = UIColor.systemBlue.cgColor
        highlightLayer.cornerRadius = 6.0
        self.layer.addSublayer(highlightLayer)
        
        // 3. Draw the Grid of Text Layers
        let standardTextColor = KeyboardTheme.textColor(isDark: isDark)
        
        for (index, altChar) in alternates.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let charFrame = CGRect(x: CGFloat(col) * slotWidth,
                                   y: CGFloat(row) * slotHeight,
                                   width: slotWidth,
                                   height: slotHeight)
            
            let textLayer = CATextLayer()
            textLayer.string = altChar
            textLayer.font = UIFont.systemFont(ofSize: 24, weight: .regular)
            textLayer.fontSize = 24
            textLayer.alignmentMode = .center
            textLayer.contentsScale = self.traitCollection.displayScale
            
            // Vertically center the text within its slot
            let fontHeight = UIFont.systemFont(ofSize: 24).lineHeight
            let textY = charFrame.origin.y + (charFrame.height - fontHeight) / 2.0
            textLayer.frame = CGRect(x: charFrame.origin.x, y: textY, width: charFrame.width, height: fontHeight)
            
            textLayer.foregroundColor = standardTextColor
            
            self.layer.addSublayer(textLayer)
            textLayers.append(textLayer)
        }
        
        // Highlight the default first item
        updateHighlight(to: 0)
    }
    
    // MARK: - Interaction
    
    func handlePan(touchPointInKeyboard: CGPoint) {
        // Convert the touch point from the main keyboard view into our local grid coordinates
        let localPoint = self.convert(touchPointInKeyboard, from: self.superview)
        
        // Calculate which row and column the finger is currently hovering over
        var col = Int(localPoint.x / slotWidth)
        var row = Int(localPoint.y / slotHeight)
        
        // Clamp to prevent out-of-bounds crashing if they drag wildly outside the bubble
        col = max(0, min(col, columns - 1))
        row = max(0, min(row, rows - 1))
        
        var newIndex = (row * columns) + col
        
        // Safety check: if the last row isn't completely full, clamping to the last column
        // might give an index that doesn't exist in the array.
        if newIndex >= alternates.count {
            newIndex = alternates.count - 1
        }
        
        updateHighlight(to: newIndex)
    }
    
    private func updateHighlight(to index: Int) {
        guard index != highlightedIndex, index >= 0, index < alternates.count else { return }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true) // Instant snap, no animations
        
        // 1. Revert old highlighted text to normal color
        let isDark = KeyboardTheme.isDark(traitCollection: self.traitCollection)
        if highlightedIndex >= 0 && highlightedIndex < textLayers.count {
            textLayers[highlightedIndex].foregroundColor = KeyboardTheme.textColor(isDark: isDark)
        }
        
        // 2. Update new index
        highlightedIndex = index
        
        // 3. Move the blue highlight layer to the new slot
        let row = index / columns
        let col = index % columns
        
        let highlightRect = CGRect(x: CGFloat(col) * slotWidth,
                                   y: CGFloat(row) * slotHeight,
                                   width: slotWidth,
                                   height: slotHeight).insetBy(dx: 4, dy: 4) // Slight inset for padding
        
        highlightLayer.path = UIBezierPath(roundedRect: highlightRect, cornerRadius: 6.0).cgPath
        
        // 4. Change new highlighted text to white so it contrasts the blue background
        textLayers[highlightedIndex].foregroundColor = UIColor.white.cgColor
        
        CATransaction.commit()
    }
    
    func getSelectedCharacter() -> String? {
        guard highlightedIndex >= 0 && highlightedIndex < alternates.count else { return nil }
        return alternates[highlightedIndex]
    }
}
