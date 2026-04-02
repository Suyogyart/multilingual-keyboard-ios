//
//  KeyboardLanguage.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 01/04/26.
//

import Foundation

enum KeyboardLanguage: String, CaseIterable {
    case english = "en-US"
    case nepaliTraditional = "np-trad"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .nepaliTraditional: return "नेपाली (Traditional)"
        }
    }
    
    func filename(for type: KeyboardLayoutType) -> String {
        switch type {
        case .letters: return rawValue
        case .numbers: return "\(rawValue)-numbers"
        case .symbols: return "\(rawValue)-symbols"
        }
    }
}

enum KeyboardLayoutType {
    case letters
    case numbers
    case symbols
}
