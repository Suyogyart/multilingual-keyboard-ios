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
