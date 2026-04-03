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
    case newaTraditional = "newa-trad"
    case nepaliTransliteration = "np-translit"
    case newaTransliteration = "newa-translit"
    
    var displayName: String {
        switch self {
        case .english: return "English (US)"
        case .nepaliTraditional: return "नेपाली (Traditional)"
        case .newaTraditional: return "𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵 (Traditional)"
        case .nepaliTransliteration: return "नेपाली (Transliteration)"
        case .newaTransliteration: return "𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵 (Transliteration)"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .english: return "English (US)"
        case .nepaliTraditional: return "नेपाली"
        case .newaTraditional: return "𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵"
        case .nepaliTransliteration: return "EN -> नेपाली"
        case .newaTransliteration: return "EN -> 𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵"
        }
    }
    
    var hasSuggestions: Bool {
        switch self {
        case .english: return true
        case .nepaliTraditional, .newaTraditional: return false
        case .nepaliTransliteration, .newaTransliteration: return true
        }
    }
    
    func filename(for type: KeyboardLayoutType) -> String {
        switch type {
        case .letters: return rawValue
        case .numbers: return "\(rawValue)-numbers"
        case .symbols: return "\(rawValue)-symbols"
        case .emoji: return ""
        }
    }
}

enum KeyboardLayoutType {
    case letters
    case numbers
    case symbols
    case emoji
}
