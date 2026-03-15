//
//  KeyboardTheme.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 14/03/26.
//

import UIKit

// MARK: - Native Theme Manager
struct KeyboardTheme {
    static func isDark(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
    
    static func keyColor(isSpecial: Bool, isDark: Bool) -> CGColor {
        if isDark {
            // Dark Mode: Normal keys are lighter gray, Special keys are darker gray
            return isSpecial ? UIColor(white: 0.25, alpha: 1.0).cgColor : UIColor(white: 0.45, alpha: 1.0).cgColor
        } else {
            // Light Mode: Normal keys are white, Special keys are light gray
            return isSpecial ? UIColor(red: 174/255, green: 179/255, blue: 190/255, alpha: 1.0).cgColor : UIColor.white.cgColor
        }
    }
    
    static func pressedKeyColor(isSpecial: Bool, isDark: Bool) -> CGColor {
        // When pressed, the colors swap (Normal becomes Special color, Special becomes Normal color)
        return keyColor(isSpecial: !isSpecial, isDark: isDark)
    }
    
    static func textColor(isDark: Bool) -> CGColor {
        return isDark ? UIColor.white.cgColor : UIColor.black.cgColor
    }
    
    static func shadowColor(isDark: Bool) -> CGColor {
        // Light mode has a grayish shadow, dark mode uses pure black
        return isDark ? UIColor.black.cgColor : UIColor(red: 137/255, green: 138/255, blue: 141/255, alpha: 1.0).cgColor
    }
}

enum ThemeType: String, CaseIterable {
    case system = "Default"
    case light = "Light"
    case dark = "Dark"
    case fossil = "Dark Fossil"
    case highContrast = "High Contrast"
    case redGradient = "Sunset Red"
    case blueGradient = "Ocean Blue"
    
    var displayName: String { self.rawValue }
}

struct ThemeColors {
    let keyboardBackground: UIColor
    let keyBackground: UIColor
    let specialKeyBackground: UIColor
    let textColor: UIColor
    let shadowColor: UIColor
}
