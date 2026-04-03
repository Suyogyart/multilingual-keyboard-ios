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

    /// Prefixes used to match `NepaliTransliterationDictionary` entries (Devanagari words).
    private static func devanagariPrefixesForDictionaryLookup(_ roman: String) -> [String] {
        let p = transliterate(roman)
        guard !p.isEmpty else { return [] }
        var prefixes = [p]
        if p.hasSuffix(virama), p.count > virama.count {
            let stripped = String(p.dropLast(virama.count))
            if !stripped.isEmpty { prefixes.append(stripped) }
        }
        return prefixes
    }

    /// Suggestion strings (Devanagari), primary first — rule-based transliteration plus `NepaliTransliterationDictionary` prefix matches (same idea as the web keyboard).
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

        let dictPrefixes = devanagariPrefixesForDictionaryLookup(buffer)
        if !dictPrefixes.isEmpty {
            for w in NepaliTransliterationDictionary.devanagariWords {
                guard suggestions.count < limit else { break }
                guard !seen.contains(w) else { continue }
                guard dictPrefixes.contains(where: { w.hasPrefix($0) }) else { continue }
                seen.insert(w)
                suggestions.append(w)
            }
        }

        return Array(suggestions.prefix(limit))
    }

    /// Devanagari → Nepal Lipi (Newa), from Callijatra `transliterate.html` `devaToNewa`.
    static func devaToNewa(_ text: String) -> String {
        let triples: [(String, String)] = [
            ("\u{0919}\u{094D}\u{0939}", scalarString(0x11413)),
            ("\u{091E}\u{094D}\u{0939}", scalarString(0x11419)),
            ("\u{0930}\u{094D}\u{0939}", scalarString(0x1142D)),
        ]
        var single: [String: String] = [:]
        func map(_ dev: UInt32, _ newa: UInt32) {
            single[String(UnicodeScalar(dev)!)] = scalarString(newa)
        }
        map(0x0905, 0x11400); map(0x0906, 0x11401); map(0x0907, 0x11402); map(0x0908, 0x11403)
        map(0x0909, 0x11404); map(0x090A, 0x11405); map(0x090B, 0x11406); map(0x090C, 0x11408)
        map(0x090F, 0x1140A); map(0x0910, 0x1140B); map(0x0913, 0x1140C); map(0x0914, 0x1140D)
        map(0x0915, 0x1140E); map(0x0916, 0x1140F); map(0x0917, 0x11410); map(0x0918, 0x11411)
        map(0x0919, 0x11412); map(0x091A, 0x11414); map(0x091B, 0x11415); map(0x091C, 0x11416)
        map(0x091D, 0x11417); map(0x091E, 0x11418); map(0x091F, 0x1141A); map(0x0920, 0x1141B)
        map(0x0921, 0x1141C); map(0x0922, 0x1141D); map(0x0923, 0x1141E); map(0x0924, 0x1141F)
        map(0x0925, 0x11420); map(0x0926, 0x11421); map(0x0927, 0x11422); map(0x0928, 0x11423)
        map(0x092A, 0x11425); map(0x092B, 0x11426); map(0x092C, 0x11427); map(0x092D, 0x11428)
        map(0x092E, 0x11429); map(0x092F, 0x1142B); map(0x0930, 0x1142C); map(0x0932, 0x1142E)
        map(0x0935, 0x11430); map(0x0936, 0x11431); map(0x0937, 0x11432); map(0x0938, 0x11433)
        map(0x0939, 0x11434); map(0x0933, 0x1142F)
        map(0x093E, 0x11435); map(0x093F, 0x11436); map(0x0940, 0x11437); map(0x0941, 0x11438)
        map(0x0942, 0x11439); map(0x0943, 0x1143A); map(0x0944, 0x1143B); map(0x0947, 0x1143E)
        map(0x0948, 0x1143F)
        map(0x094B, 0x11440); map(0x094C, 0x11441); map(0x094D, 0x11442); map(0x0901, 0x11443)
        map(0x0902, 0x11444); map(0x0903, 0x11445); map(0x093C, 0x11446); map(0x0950, 0x11449)
        map(0x0964, 0x1144B); map(0x0965, 0x1144C)
        map(0x0966, 0x11450); map(0x0967, 0x11451); map(0x0968, 0x11452); map(0x0969, 0x11453)
        map(0x096A, 0x11454); map(0x096B, 0x11455); map(0x096C, 0x11456); map(0x096D, 0x11457)
        map(0x096E, 0x11458); map(0x096F, 0x11459)
        map(0x0960, 0x11407); map(0x0961, 0x11409)
        map(0x0962, 0x1143C); map(0x0963, 0x1143D)

        var scalars = Array(text.unicodeScalars)
        var pos = 0
        var out = ""
        while pos < scalars.count {
            var matchedTriple = false
            if pos + 3 <= scalars.count {
                let tri = scalars[pos..<(pos + 3)].map { String($0) }.joined()
                for (key, val) in triples where tri == key {
                    out += val
                    pos += 3
                    matchedTriple = true
                    break
                }
            }
            if matchedTriple { continue }
            let s = String(scalars[pos])
            out += single[s] ?? s
            pos += 1
        }
        return out
    }

    private static func scalarString(_ v: UInt32) -> String {
        guard let us = UnicodeScalar(v) else { return "" }
        return String(us)
    }

    static func transliterateToNewa(_ roman: String) -> String {
        devaToNewa(transliterate(roman))
    }

    private static let newaVirama = "\u{11442}"

    private static func newaPrefixesForDictionaryLookup(_ roman: String) -> [String] {
        let p = transliterateToNewa(roman)
        guard !p.isEmpty else { return [] }
        var prefixes = [p]
        if p.hasSuffix(newaVirama), p.count > newaVirama.count {
            let stripped = String(p.dropLast(newaVirama.count))
            if !stripped.isEmpty { prefixes.append(stripped) }
        }
        return prefixes
    }

    /// Transliteration suggestions in Newa: Roman → Devanagari suggestions (including Nepali dictionary) mapped with `devaToNewa`, then prefix matches from `NewaTransliterationDictionary`.
    static func suggestionTextsNewa(for buffer: String, limit: Int = 5) -> [String] {
        let devaList = suggestionTexts(for: buffer, limit: max(limit * 3, 15))
        var seen = Set<String>()
        var out: [String] = []
        for d in devaList {
            let n = devaToNewa(d)
            guard !seen.contains(n) else { continue }
            seen.insert(n)
            out.append(n)
            if out.count >= limit { return out }
        }
        let newaPrefixes = newaPrefixesForDictionaryLookup(buffer)
        guard !newaPrefixes.isEmpty else { return out }
        for w in NewaTransliterationDictionary.newaWords {
            guard out.count < limit else { break }
            guard !seen.contains(w) else { continue }
            guard newaPrefixes.contains(where: { w.hasPrefix($0) }) else { continue }
            seen.insert(w)
            out.append(w)
        }
        return out
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
