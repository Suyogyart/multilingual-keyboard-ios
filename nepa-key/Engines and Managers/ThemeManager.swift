//
//  ThemeManager.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//


import UIKit

class ThemeManager {
    static func current(traitCollection: UITraitCollection) -> ThemeColors {
        let theme = KeyboardSettings.shared.selectedTheme
        let isDark = traitCollection.userInterfaceStyle == .dark
        
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
                shadowColor: UIColor.black.withAlphaComponent(0.4),
                interfaceStyle: .dark
            )
        case .highContrast:
            return ThemeColors(
                keyboardBackground: .black,
                keyBackground: .white,
                specialKeyBackground: .lightGray,
                textColor: .black,
                shadowColor: .clear,
                interfaceStyle: .dark
            )
        case .red:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.4, green: 0.0, blue: 0.1, alpha: 1.0),
                keyBackground: UIColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 1.0),
                specialKeyBackground: UIColor(red: 0.3, green: 0.0, blue: 0.05, alpha: 1.0),
                textColor: .white,
                shadowColor: UIColor.black.withAlphaComponent(0.3),
                interfaceStyle: .dark
            )
        case .blue:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.05, green: 0.15, blue: 0.3, alpha: 1.0),
                keyBackground: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
                specialKeyBackground: UIColor(red: 0.0, green: 0.1, blue: 0.2, alpha: 1.0),
                textColor: .white,
                shadowColor: UIColor.black.withAlphaComponent(0.3),
                interfaceStyle: .dark
            )
            
        case .redGradient:
            return ThemeColors(
                keyboardBackground: UIColor(white: 0.1, alpha: 1.0),
                keyBackground: .clear, // Transparent to show gradient below
                specialKeyBackground: UIColor(white: 1.0, alpha: 0.1),
                textColor: .white,
                shadowColor: .clear,
                gradientColors: [UIColor.systemRed, UIColor.systemOrange],
                isLiquidGlass: false,
                interfaceStyle: .dark
            )

        case .liquidGlass:
            return ThemeColors(
                keyboardBackground: UIColor(white: 0.2, alpha: 1.0),
                keyBackground: UIColor(white: 1.0, alpha: 0.2), // Frosted look
                specialKeyBackground: UIColor(white: 1.0, alpha: 0.1),
                textColor: .white,
                shadowColor: .black.withAlphaComponent(0.2),
                gradientColors: [UIColor(white: 1.0, alpha: 0.3), UIColor(white: 1.0, alpha: 0.05)],
                isLiquidGlass: true,
                interfaceStyle: .dark
            )
            
        case .matcha:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.89, green: 0.93, blue: 0.88, alpha: 1.0),
                keyBackground: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8),
                specialKeyBackground: UIColor(red: 0.76, green: 0.86, blue: 0.75, alpha: 1.0),
                textColor: UIColor(red: 0.2, green: 0.3, blue: 0.2, alpha: 1.0),
                shadowColor: UIColor(red: 0.6, green: 0.7, blue: 0.6, alpha: 0.5),
                gradientColors: nil,
                isLiquidGlass: false,
                interfaceStyle: .light
            )
            
        case .himalayanDawn:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 1.0),
                keyBackground: .clear,
                specialKeyBackground: UIColor(white: 1.0, alpha: 0.15),
                textColor: .white,
                shadowColor: UIColor.black.withAlphaComponent(0.4),
                gradientColors: [
                    UIColor(red: 0.35, green: 0.2, blue: 0.45, alpha: 1.0), // Deep Purple
                    UIColor(red: 0.85, green: 0.4, blue: 0.4, alpha: 1.0)  // Dawn Pink/Orange
                ],
                isLiquidGlass: false,
                interfaceStyle: .dark
            )
            
        case .heritageTerracotta:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.78, green: 0.42, blue: 0.31, alpha: 1.0), // Brick/Clay base
                keyBackground: UIColor(red: 0.88, green: 0.53, blue: 0.42, alpha: 1.0),
                specialKeyBackground: UIColor(red: 0.65, green: 0.32, blue: 0.22, alpha: 1.0),
                textColor: .white,
                shadowColor: UIColor(red: 0.4, green: 0.15, blue: 0.1, alpha: 0.5),
                gradientColors: nil,
                isLiquidGlass: false,
                interfaceStyle: .dark
            )
            
        case .cyberGlass:
            return ThemeColors(
                keyboardBackground: UIColor(red: 0.05, green: 0.05, blue: 0.08, alpha: 1.0),
                keyBackground: UIColor(white: 1.0, alpha: 0.1), // Glassy keys
                specialKeyBackground: UIColor(white: 1.0, alpha: 0.05),
                textColor: UIColor(red: 0.0, green: 1.0, blue: 0.8, alpha: 1.0), // Neon Cyan text
                shadowColor: .black,
                gradientColors: [
                    UIColor(white: 1.0, alpha: 0.15),
                    UIColor(white: 1.0, alpha: 0.02)
                ],
                isLiquidGlass: true,
                interfaceStyle: .dark
            )
        case .system:
            return isDark ? darkTheme() : lightTheme()
        }
    }
    
    // Update the helpers to accept the style
    private static func lightTheme(style: UIUserInterfaceStyle = .light) -> ThemeColors {
        return ThemeColors(
            keyboardBackground: UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0),
            keyBackground: .white,
            specialKeyBackground: UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1.0),
            textColor: .black,
            shadowColor: UIColor.black.withAlphaComponent(0.3),
            gradientColors: nil,
            isLiquidGlass: false,
            interfaceStyle: style // Inherits .light or .unspecified
        )
    }
    
    private static func darkTheme(style: UIUserInterfaceStyle = .dark) -> ThemeColors {
        return ThemeColors(
            keyboardBackground: UIColor(white: 0.1, alpha: 1.0),
            keyBackground: UIColor(white: 0.25, alpha: 1.0),
            specialKeyBackground: UIColor(white: 0.15, alpha: 1.0),
            textColor: .white,
            shadowColor: UIColor.black.withAlphaComponent(0.5),
            gradientColors: nil,
            isLiquidGlass: false,
            interfaceStyle: style // Inherits .dark or .unspecified
        )
    }
}
