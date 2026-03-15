//
//  ThemeManager.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//


import UIKit

class ThemeManager {
    static func current() -> ThemeColors {
        let theme = KeyboardSettings.shared.selectedTheme
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark
        
        switch theme {
        case .light:
            return lightTheme()
        case .dark:
            return darkTheme()
        case .fossil:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.24, green: 0.22, blue: 0.20, alpha: 1.0),
                keyBackground: UIColor(red: 0.35, green: 0.32, blue: 0.29, alpha: 1.0),
                specialKeyBackground: UIColor(red: 0.18, green: 0.16, blue: 0.15, alpha: 1.0),
                textColor: .white,
                shadowColor: UIColor.black.withAlphaComponent(0.4)
            )
        case .highContrast:
            return ThemeColors(
                keyboardBackground: .black,
                keyBackground: .white,
                specialKeyBackground: .lightGray,
                textColor: .black,
                shadowColor: .clear
            )
        case .red:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.4, green: 0.0, blue: 0.1, alpha: 1.0),
                keyBackground: UIColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 1.0),
                specialKeyBackground: UIColor(red: 0.3, green: 0.0, blue: 0.05, alpha: 1.0),
                textColor: .white,
                shadowColor: UIColor.black.withAlphaComponent(0.3)
            )
        case .blue:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.05, green: 0.15, blue: 0.3, alpha: 1.0),
                keyBackground: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
                specialKeyBackground: UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0),
                textColor: .white,
                shadowColor: UIColor.black.withAlphaComponent(0.3)
            )
            
        case .redGradient:
            return ThemeColors(
                keyboardBackground: UIColor(white: 0.1, alpha: 1.0),
                keyBackground: .clear, // Transparent to show gradient below
                specialKeyBackground: UIColor(white: 1.0, alpha: 0.1),
                textColor: .white,
                shadowColor: .clear,
                gradientColors: [UIColor.systemRed, UIColor.systemOrange],
                isLiquidGlass: false
            )

        case .liquidGlass:
            return ThemeColors(
                keyboardBackground: UIColor(white: 0.2, alpha: 1.0),
                keyBackground: UIColor(white: 1.0, alpha: 0.2), // Frosted look
                specialKeyBackground: UIColor(white: 1.0, alpha: 0.1),
                textColor: .white,
                shadowColor: .black.withAlphaComponent(0.2),
                gradientColors: [UIColor(white: 1.0, alpha: 0.3), UIColor(white: 1.0, alpha: 0.05)],
                isLiquidGlass: true
            )
        case .system:
            return isDark ? darkTheme() : lightTheme()
        }
    }
    
    private static func lightTheme() -> ThemeColors {
        return ThemeColors(
            keyboardBackground: UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0),
            keyBackground: .white,
            specialKeyBackground: UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1.0),
            textColor: .black,
            shadowColor: UIColor.black.withAlphaComponent(0.3)
        )
    }
    
    private static func darkTheme() -> ThemeColors {
        return ThemeColors(
            keyboardBackground: UIColor(white: 0.1, alpha: 1.0),
            keyBackground: UIColor(white: 0.25, alpha: 1.0),
            specialKeyBackground: UIColor(white: 0.15, alpha: 1.0),
            textColor: .white,
            shadowColor: UIColor.black.withAlphaComponent(0.5)
        )
    }
}
