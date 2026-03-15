//
//  AppGroupDefault.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//


import Foundation

// 1. The Property Wrapper
// This handles the actual reading and writing to the App Group UserDefaults
@propertyWrapper
struct AppGroupDefault<T> {
    let key: String
    let defaultValue: T
    let defaults: UserDefaults

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = UserDefaults(suiteName: "group.com.callijatra.multilingual-keyboard") ?? .standard
    }

    var wrappedValue: T {
        get {
            defaults.synchronize()
            return defaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            defaults.set(newValue, forKey: key)
            defaults.synchronize()
        }
    }
}

// 2. The Settings Manager
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
}
