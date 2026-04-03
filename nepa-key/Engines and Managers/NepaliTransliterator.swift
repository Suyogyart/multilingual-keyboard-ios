//
//  NepaliTransliterator.swift
//  multilingual-keyboard
//
//  Roman → Devanagari transliteration ported from Callijatra transliterate.html
//  (NepaliTransliterator.kt pattern). Dictionary-powered suggestions omitted for extension size.
//

import Foundation

enum NepaliTransliterator {

    private static let consonant = 1
    private static let vowel = 2
    private static let diacritic = 3

    private static let virama = "\u{094D}"

    private struct Rule {
        let roman: String
        let deva: String
        let type: Int
    }

    /// Longest-first within groups; order matches web `findMatch` iteration.
    private static let rules: [Rule] = [
        Rule(roman: "ksh", deva: "\u{0915}\u{094D}\u{0937}", type: consonant),
        Rule(roman: "Ksh", deva: "\u{0915}\u{094D}\u{0937}", type: consonant),
        Rule(roman: "chh", deva: "\u{091B}", type: consonant),
        Rule(roman: "kh", deva: "\u{0916}", type: consonant),
        Rule(roman: "Kh", deva: "\u{0916}", type: consonant),
        Rule(roman: "gh", deva: "\u{0918}", type: consonant),
        Rule(roman: "Gh", deva: "\u{0918}", type: consonant),
        Rule(roman: "Ch", deva: "\u{091B}", type: consonant),
        Rule(roman: "ch", deva: "\u{091A}", type: consonant),
        Rule(roman: "jh", deva: "\u{091D}", type: consonant),
        Rule(roman: "Jh", deva: "\u{091D}", type: consonant),
        Rule(roman: "Th", deva: "\u{0920}", type: consonant),
        Rule(roman: "Dh", deva: "\u{0922}", type: consonant),
        Rule(roman: "th", deva: "\u{0925}", type: consonant),
        Rule(roman: "dh", deva: "\u{0927}", type: consonant),
        Rule(roman: "ph", deva: "\u{092B}", type: consonant),
        Rule(roman: "Ph", deva: "\u{092B}", type: consonant),
        Rule(roman: "bh", deva: "\u{092D}", type: consonant),
        Rule(roman: "Bh", deva: "\u{092D}", type: consonant),
        Rule(roman: "Sh", deva: "\u{0937}", type: consonant),
        Rule(roman: "sh", deva: "\u{0936}", type: consonant),
        Rule(roman: "nh", deva: "\u{091E}", type: consonant),
        Rule(roman: "Nh", deva: "\u{091E}", type: consonant),
        Rule(roman: "ng", deva: "\u{0919}", type: consonant),
        Rule(roman: "Ng", deva: "\u{0919}", type: consonant),
        Rule(roman: "hm", deva: "\u{0939}\u{094D}\u{092E}", type: consonant),
        Rule(roman: "hn", deva: "\u{0939}\u{094D}\u{0928}", type: consonant),
        Rule(roman: "lh", deva: "\u{0933}", type: consonant),
        Rule(roman: "Lh", deva: "\u{0933}", type: consonant),
        Rule(roman: "tr", deva: "\u{0924}\u{094D}\u{0930}", type: consonant),
        Rule(roman: "Tr", deva: "\u{0924}\u{094D}\u{0930}", type: consonant),
        Rule(roman: "gn", deva: "\u{091C}\u{094D}\u{091E}", type: consonant),
        Rule(roman: "Gn", deva: "\u{091C}\u{094D}\u{091E}", type: consonant),
        Rule(roman: "aa", deva: "\u{0906}", type: vowel),
        Rule(roman: "ii", deva: "\u{0908}", type: vowel),
        Rule(roman: "uu", deva: "\u{090A}", type: vowel),
        Rule(roman: "ai", deva: "\u{0910}", type: vowel),
        Rule(roman: "au", deva: "\u{0914}", type: vowel),
        Rule(roman: "ri", deva: "\u{090B}", type: vowel),
        Rule(roman: "ee", deva: "\u{0908}", type: vowel),
        Rule(roman: "oo", deva: "\u{090A}", type: vowel),
        Rule(roman: "T", deva: "\u{091F}", type: consonant),
        Rule(roman: "D", deva: "\u{0921}", type: consonant),
        Rule(roman: "N", deva: "\u{0923}", type: consonant),
        Rule(roman: "F", deva: "\u{092B}", type: consonant),
        Rule(roman: "X", deva: "\u{0915}\u{094D}\u{0937}", type: consonant),
        Rule(roman: "Z", deva: "\u{091C}\u{094D}\u{091E}", type: consonant),
        Rule(roman: "Q", deva: "\u{0915}\u{094D}\u{0935}", type: consonant),
        Rule(roman: "C", deva: "\u{091B}", type: consonant),
        Rule(roman: "B", deva: "\u{092D}", type: consonant),
        Rule(roman: "L", deva: "\u{0933}", type: consonant),
        Rule(roman: "k", deva: "\u{0915}", type: consonant),
        Rule(roman: "g", deva: "\u{0917}", type: consonant),
        Rule(roman: "c", deva: "\u{091A}", type: consonant),
        Rule(roman: "j", deva: "\u{091C}", type: consonant),
        Rule(roman: "t", deva: "\u{0924}", type: consonant),
        Rule(roman: "d", deva: "\u{0926}", type: consonant),
        Rule(roman: "n", deva: "\u{0928}", type: consonant),
        Rule(roman: "p", deva: "\u{092A}", type: consonant),
        Rule(roman: "b", deva: "\u{092C}", type: consonant),
        Rule(roman: "m", deva: "\u{092E}", type: consonant),
        Rule(roman: "y", deva: "\u{092F}", type: consonant),
        Rule(roman: "r", deva: "\u{0930}", type: consonant),
        Rule(roman: "l", deva: "\u{0932}", type: consonant),
        Rule(roman: "v", deva: "\u{0935}", type: consonant),
        Rule(roman: "w", deva: "\u{0935}", type: consonant),
        Rule(roman: "s", deva: "\u{0938}", type: consonant),
        Rule(roman: "S", deva: "\u{0938}", type: consonant),
        Rule(roman: "h", deva: "\u{0939}", type: consonant),
        Rule(roman: "f", deva: "\u{092B}", type: consonant),
        Rule(roman: "x", deva: "\u{0915}\u{094D}\u{0937}", type: consonant),
        Rule(roman: "z", deva: "\u{091D}", type: consonant),
        Rule(roman: "A", deva: "\u{0906}", type: vowel),
        Rule(roman: "I", deva: "\u{0908}", type: vowel),
        Rule(roman: "U", deva: "\u{090A}", type: vowel),
        Rule(roman: "E", deva: "\u{0910}", type: vowel),
        Rule(roman: "O", deva: "\u{0914}", type: vowel),
        Rule(roman: "a", deva: "\u{0905}", type: vowel),
        Rule(roman: "i", deva: "\u{0907}", type: vowel),
        Rule(roman: "u", deva: "\u{0909}", type: vowel),
        Rule(roman: "e", deva: "\u{090F}", type: vowel),
        Rule(roman: "o", deva: "\u{0913}", type: vowel),
        Rule(roman: "M", deva: "\u{0902}", type: diacritic),
        Rule(roman: "H", deva: "\u{0903}", type: diacritic),
        Rule(roman: "~", deva: "\u{0901}", type: diacritic),
        Rule(roman: "|", deva: "\u{094D}", type: diacritic),
    ]

    private static let matraMap: [String: String] = [
        "\u{0905}": "",
        "\u{0906}": "\u{093E}",
        "\u{0907}": "\u{093F}",
        "\u{0908}": "\u{0940}",
        "\u{0909}": "\u{0941}",
        "\u{090A}": "\u{0942}",
        "\u{090F}": "\u{0947}",
        "\u{0910}": "\u{0948}",
        "\u{0913}": "\u{094B}",
        "\u{0914}": "\u{094C}",
        "\u{090B}": "\u{0943}",
    ]

    private static let devanagariDigits: [Character: String] = [
        "0": "\u{0966}", "1": "\u{0967}", "2": "\u{0968}", "3": "\u{0969}", "4": "\u{096A}",
        "5": "\u{096B}", "6": "\u{096C}", "7": "\u{096D}", "8": "\u{096E}", "9": "\u{096F}",
    ]

    private static let punctuationMap: [String: String] = [
        "..": "\u{0965}",
        ".": "\u{0964}",
        ",": ",",
        "!": "!",
        "?": "?",
        "(": "(",
        ")": ")",
        "-": "-",
        "'": "\u{093D}",
    ]

    static func transliterate(_ input: String) -> String {
        var result = ""
        var i = input.startIndex
        let end = input.endIndex
        var prevConsonant = false

        while i < end {
            guard let m = matchRule(input, at: i) else {
                result.append(input[i])
                prevConsonant = false
                i = input.index(after: i)
                continue
            }
            if m.type == consonant {
                if prevConsonant { result += virama }
                result += m.deva
                prevConsonant = true
            } else if m.type == vowel {
                if prevConsonant, let matra = matraMap[m.deva] {
                    result += matra
                } else {
                    result += m.deva
                }
                prevConsonant = false
            } else {
                result += m.deva
                prevConsonant = false
            }
            i = input.index(i, offsetBy: m.roman.count)
        }
        return result
    }

    private static func matchRule(_ input: String, at pos: String.Index) -> Rule? {
        let tail = String(input[pos...])
        for r in rules where tail.hasPrefix(r.roman) {
            return r
        }
        return nil
    }

    /// Suggestion strings (Devanagari), primary first — mirrors web `getSuggestions` without dictionary.
    static func suggestionTexts(for buffer: String, limit: Int = 9) -> [String] {
        guard !buffer.isEmpty else { return [] }

        var suggestions: [String] = []
        var seen = Set<String>()

        func addUnique(_ text: String) {
            guard !seen.contains(text) else { return }
            seen.insert(text)
            suggestions.append(text)
        }

        let main = transliterate(buffer)
        addUnique(main)

        let withVirama = transliterate(buffer + "|")
        if withVirama != main { addUnique(withVirama) }

        if let lastCh = buffer.last {
            if "nmNM".contains(lastCh) {
                var base = buffer
                base.removeLast()
                var baseT = transliterate(base)
                if baseT.hasSuffix(virama) {
                    baseT = String(baseT.dropLast(virama.count))
                }
                addUnique(baseT + "\u{0902}")
            }
            if lastCh == "n" || lastCh == "N" {
                var base2 = buffer
                base2.removeLast()
                var base2T = transliterate(base2)
                if base2T.hasSuffix(virama) {
                    base2T = String(base2T.dropLast(virama.count))
                }
                addUnique(base2T + "\u{0901}")
            }
        }

        let vowelAlts: [String: String] = [
            "a": "aa", "i": "ii", "u": "uu", "e": "ai", "o": "au",
            "aa": "a", "ii": "i", "uu": "u", "ai": "e", "au": "o",
            "ee": "ii", "oo": "uu",
        ]
        for vk in vowelAlts.keys.sorted(by: { $0.count > $1.count }) {
            guard let alt = vowelAlts[vk], buffer.hasSuffix(vk) else { continue }
            let altBuf = String(buffer.dropLast(vk.count)) + alt
            addUnique(transliterate(altBuf))
        }

        let capAlts: [Character: Character] = [
            "t": "T", "d": "D", "n": "N", "s": "S", "b": "B", "c": "C", "l": "L",
        ]
        if let last = buffer.last, let rep = capAlts[last] {
            var capBuf = buffer
            capBuf.removeLast()
            capBuf.append(rep)
            addUnique(transliterate(capBuf))
        }

        if buffer.hasSuffix("sh") {
            let altBuf = String(buffer.dropLast(2)) + "Sh"
            addUnique(transliterate(altBuf))
        }
        if buffer.hasSuffix("Sh") {
            let altBuf = String(buffer.dropLast(2)) + "sh"
            addUnique(transliterate(altBuf))
        }

        if buffer.last == "h", buffer.count >= 2 {
            let noH = String(buffer.dropLast())
            addUnique(transliterate(noH))
        }

        return Array(suggestions.prefix(limit))
    }

    static func devanagariDigit(for asciiDigit: Character) -> String? {
        devanagariDigits[asciiDigit]
    }

    /// Single-char or two-char (`..`) punctuation from web `punctuation` map.
    static func devanagariPunctuation(single: Character) -> String? {
        punctuationMap[String(single)]
    }

    static func devanagariPunctuation(twoChar: String) -> String? {
        punctuationMap[twoChar]
    }
}
