//
//  KeyboardSettings.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//


// The Settings Manager
// A singleton that holds all your settings in one highly-typed, safe place.
class KeyboardSettings {
    
    static let shared = KeyboardSettings()
    private init() {}
    
    // Adjust Keyboard Height (1.0 is standard, 0.8 is small, 1.2 is large)
    @AppGroupDefault(key: "keyboardHeightScale", defaultValue: 1.0)
    var keyboardHeightScale: Float
    
    // Sound & Haptics
    @AppGroupDefault(key: "enableSounds", defaultValue: true)
    var enableSounds: Bool
    
    @AppGroupDefault(key: "enableHaptics", defaultValue: true)
    var enableHaptics: Bool
    
    // Long Press Delay (0.3 seconds is standard iOS feel)
    @AppGroupDefault(key: "longPressDelay", defaultValue: 0.3)
    var longPressDelay: Double
    
    @AppGroupDefault(key: "selectedTheme", defaultValue: ThemeType.system.rawValue)
    var selectedThemeRaw: String
    
    var selectedTheme: ThemeType {
        get { ThemeType(rawValue: selectedThemeRaw) ?? .system }
        set { selectedThemeRaw = newValue.rawValue }
    }
    
    @AppGroupDefault(key: "selectedLanguage", defaultValue: "en-US")
    var selectedLanguage: String
}
