//
//  KeyboardLayout.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

struct KeyboardLayout: Decodable {
    let languageCode: String
    var rows: [[KeyModel]]
    
    // MARK: - Static Default Fallback
    // This completely bypasses Disk I/O and JSON parsing for a 0ms load time.
    static let defaultEnglish = KeyboardLayout(
        languageCode: KeyboardLanguage.english.rawValue,
        rows: [
            // ROW 1
            [
                KeyModel(id: "q", primaryLabel: "q", shiftLabel: "Q", fontSize: nil, isAction: false, alternates: ["1"], widthMultiplier: 1.0),
                KeyModel(id: "w", primaryLabel: "w", shiftLabel: "W", fontSize: nil, isAction: false, alternates: ["2"], widthMultiplier: 1.0),
                KeyModel(id: "e", primaryLabel: "e", shiftLabel: "E", fontSize: nil, isAction: false, alternates: ["3", "é", "è", "ê", "ë", "ब", "क", "म", "ा", "न", "ज"], widthMultiplier: 1.0),
                KeyModel(id: "r", primaryLabel: "r", shiftLabel: "R", fontSize: nil, isAction: false, alternates: ["4"], widthMultiplier: 1.0),
                KeyModel(id: "t", primaryLabel: "t", shiftLabel: "T", fontSize: nil, isAction: false, alternates: ["5"], widthMultiplier: 1.0),
                KeyModel(id: "y", primaryLabel: "y", shiftLabel: "Y", fontSize: nil, isAction: false, alternates: ["6"], widthMultiplier: 1.0),
                KeyModel(id: "u", primaryLabel: "u", shiftLabel: "U", fontSize: nil, isAction: false, alternates: ["7", "ú", "ü"], widthMultiplier: 1.0),
                KeyModel(id: "i", primaryLabel: "i", shiftLabel: "I", fontSize: nil, isAction: false, alternates: ["8", "í", "ï"], widthMultiplier: 1.0),
                KeyModel(id: "o", primaryLabel: "o", shiftLabel: "O", fontSize: nil, isAction: false, alternates: ["9", "ó", "ö", "ô"], widthMultiplier: 1.0),
                KeyModel(id: "p", primaryLabel: "p", shiftLabel: "P", fontSize: nil, isAction: false, alternates: ["0"], widthMultiplier: 1.0)
            ],
            // ROW 2
            [
                KeyModel(id: "a", primaryLabel: "a", shiftLabel: "A", fontSize: nil, isAction: false, alternates: ["á", "ä", "æ"], widthMultiplier: 1.0),
                KeyModel(id: "s", primaryLabel: "s", shiftLabel: "S", fontSize: nil, isAction: false, alternates: ["ß", "ś"], widthMultiplier: 1.0),
                KeyModel(id: "d", primaryLabel: "d", shiftLabel: "D", fontSize: nil, isAction: false, alternates: ["đ"], widthMultiplier: 1.0),
                KeyModel(id: "f", primaryLabel: "f", shiftLabel: "F", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "g", primaryLabel: "g", shiftLabel: "G", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "h", primaryLabel: "h", shiftLabel: "H", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "j", primaryLabel: "j", shiftLabel: "J", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "k", primaryLabel: "k", shiftLabel: "K", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "l", primaryLabel: "l", shiftLabel: "L", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0)
            ],
            // ROW 3
            [
                KeyModel(id: "shift", primaryLabel: "⇧", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.5),
                KeyModel(id: "z", primaryLabel: "z", shiftLabel: "Z", fontSize: nil, isAction: false, alternates: ["ž"], widthMultiplier: 1.0),
                KeyModel(id: "x", primaryLabel: "x", shiftLabel: "X", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "c", primaryLabel: "c", shiftLabel: "C", fontSize: nil, isAction: false, alternates: ["ç", "ć"], widthMultiplier: 1.0),
                KeyModel(id: "v", primaryLabel: "v", shiftLabel: "V", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "b", primaryLabel: "b", shiftLabel: "B", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "n", primaryLabel: "n", shiftLabel: "N", fontSize: nil, isAction: false, alternates: ["ñ", "ń"], widthMultiplier: 1.0),
                KeyModel(id: "m", primaryLabel: "m", shiftLabel: "M", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "delete", primaryLabel: "⌫", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.5)
            ],
            // ROW 4
            [
                KeyModel(id: "numbers", primaryLabel: "123", shiftLabel: nil, fontSize: 16.0, isAction: true, alternates: [], widthMultiplier: 1.5),
                KeyModel(id: "globe", primaryLabel: "🌐", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "emoji", primaryLabel: "😊", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "space", primaryLabel: "", shiftLabel: nil, fontSize: nil, isAction: false, alternates: [], widthMultiplier: 4.0),
                KeyModel(id: "return", primaryLabel: "⏎", shiftLabel: nil, fontSize: 18.0, isAction: true, alternates: [], widthMultiplier: 2.0)
            ]
        ]
    )
    
    static let defaultNepali = KeyboardLayout(
        languageCode: KeyboardLanguage.nepaliTraditional.rawValue,
        rows: [
            // ROW 1
            [
                KeyModel(id: "ञ", primaryLabel: "ञ", shiftLabel: "१", fontSize: nil, isAction: false, alternates: ["ञ्", "ञा", "ञि", "ञी", "ञु", "ञू", "ञृ", "ञॄ", "ञॢ", "ञॣ", "ञे", "ञै", "ञो", "ञौ", "ञं", "ञः"], widthMultiplier: 1.0),
                KeyModel(id: "घ", primaryLabel: "घ", shiftLabel: "२", fontSize: nil, isAction: false, alternates: ["घ्", "घा", "घि", "घी", "घु", "घू", "घृ", "घॄ", "घॢ", "घॣ", "घे", "घै", "घो", "घौ", "घं", "घः"], widthMultiplier: 1.0),
                KeyModel(id: "ङ", primaryLabel: "ङ", shiftLabel: "३", fontSize: nil, isAction: false, alternates: ["ङ्", "ङा", "ङि", "ङी", "ङु", "ङू", "ङृ", "ङॄ", "ङॢ", "ङॣ", "ङे", "ङै", "ङो", "ङौ", "ङं", "ङः"], widthMultiplier: 1.0),
                KeyModel(id: "झ", primaryLabel: "झ", shiftLabel: "४", fontSize: nil, isAction: false, alternates: ["झ्", "झा", "झि", "झी", "झु", "झू", "झृ", "झॄ", "झॢ", "झॣ", "झे", "झै", "झो", "झौ", "झं", "झः"], widthMultiplier: 1.0),
                KeyModel(id: "छ", primaryLabel: "छ", shiftLabel: "५", fontSize: nil, isAction: false, alternates: ["छ्", "छा", "छि", "छी", "छु", "छू", "छृ", "छॄ", "छॢ", "छॣ", "छे", "छै", "छो", "छौ", "छं", "छः"], widthMultiplier: 1.0),
                KeyModel(id: "ट", primaryLabel: "ट", shiftLabel: "६", fontSize: nil, isAction: false, alternates: ["ट्", "टा", "टि", "टी", "टु", "टू", "टृ", "टॄ", "टॢ", "टॣ", "टे", "टै", "टो", "टौ", "टं", "टः"], widthMultiplier: 1.0),
                KeyModel(id: "ठ", primaryLabel: "ठ", shiftLabel: "७", fontSize: nil, isAction: false, alternates: ["ठ्", "ठा", "ठि", "ठी", "ठु", "ठू", "ठृ", "ठॄ", "ठॢ", "ठॣ", "ठे", "ठै", "ठो", "ठौ", "ठं", "ठः"], widthMultiplier: 1.0),
                KeyModel(id: "ड", primaryLabel: "ड", shiftLabel: "८", fontSize: nil, isAction: false, alternates: ["ड्", "डा", "डि", "डी", "डु", "डू", "डृ", "डॄ", "डॢ", "डॣ", "डे", "डै", "डो", "डौ", "डं", "डः"], widthMultiplier: 1.0),
                KeyModel(id: "ढ", primaryLabel: "ढ", shiftLabel: "९", fontSize: nil, isAction: false, alternates: ["ढ्", "ढा", "ढि", "ढी", "ढु", "ढू", "ढृ", "ढॄ", "ढॢ", "ढॣ", "ढे", "ढै", "ढो", "ढौ", "ढं", "ढः"], widthMultiplier: 1.0),
                KeyModel(id: "ण", primaryLabel: "ण", shiftLabel: "०", fontSize: nil, isAction: false, alternates: ["ण्", "णा", "णि", "णी", "णु", "णू", "णृ", "णॄ", "णॢ", "णॣ", "णे", "णै", "णो", "णौ", "णं", "णः"], widthMultiplier: 1.0),
                KeyModel(id: "्", primaryLabel: "्", shiftLabel: "ं", fontSize: nil, isAction: false, alternates: [""], widthMultiplier: 1.0)
            ],
            // ROW 2
            [
                KeyModel(id: "ध", primaryLabel: "ध", shiftLabel: "ो", fontSize: nil, isAction: false, alternates: ["ध्", "धा", "धि", "धी", "धु", "धू", "धृ", "धॄ", "धॢ", "धॣ", "धे", "धै", "धो", "धौ", "धं", "धः"], widthMultiplier: 1.0),
                KeyModel(id: "भ", primaryLabel: "भ", shiftLabel: "र्‍", fontSize: nil, isAction: false, alternates: ["भ्", "भा", "भि", "भी", "भु", "भू", "भृ", "भॄ", "भॢ", "भॣ", "भे", "भै", "भो", "भौ", "भं", "भः"], widthMultiplier: 1.0),
                KeyModel(id: "च", primaryLabel: "च", shiftLabel: "||", fontSize: nil, isAction: false, alternates: ["च्", "चा", "चि", "ची", "चु", "चू", "चृ", "चॄ", "चॢ", "चॣ", "चे", "चै", "चो", "चौ", "चं", "चः"], widthMultiplier: 1.0),
                KeyModel(id: "त", primaryLabel: "त", shiftLabel: "त्र", fontSize: nil, isAction: false, alternates: ["त्", "ता", "ति", "ती", "तु", "तू", "तृ", "तॄ", "तॢ", "तॣ", "ते", "तै", "तो", "तौ", "तं", "तः"], widthMultiplier: 1.0),
                KeyModel(id: "थ", primaryLabel: "थ", shiftLabel: "ए", fontSize: nil, isAction: false, alternates: ["थ्", "था", "थि", "थी", "थु", "थू", "थृ", "थॄ", "थॢ", "थॣ", "थे", "थै", "थो", "थौ", "थं", "थः"], widthMultiplier: 1.0),
                KeyModel(id: "ग", primaryLabel: "ग", shiftLabel: "ऐ", fontSize: nil, isAction: false, alternates: ["ग्", "गा", "गि", "गी", "गु", "गू", "गृ", "गॄ", "गॢ", "गॣ", "गे", "गै", "गो", "गौ", "गं", "गः"], widthMultiplier: 1.0),
                KeyModel(id: "ष", primaryLabel: "ष", shiftLabel: "इ", fontSize: nil, isAction: false, alternates: ["ष्", "षा", "षि", "षी", "षु", "षू", "षृ", "षॄ", "षॢ", "षॣ", "षे", "षै", "षो", "षौ", "षं", "षः"], widthMultiplier: 1.0),
                KeyModel(id: "य", primaryLabel: "य", shiftLabel: "ई", fontSize: nil, isAction: false, alternates: ["य्", "या", "यि", "यी", "यु", "यू", "यृ", "यॄ", "यॢ", "यॣ", "ये", "यै", "यो", "यौ", "यं", "यः"], widthMultiplier: 1.0),
                KeyModel(id: "उ", primaryLabel: "उ", shiftLabel: "ऊ", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "ृ", primaryLabel: "ृ", shiftLabel: " ़", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "े", primaryLabel: "े", shiftLabel: "ै", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0)
            ],
            // ROW 3
            [
                KeyModel(id: "ब", primaryLabel: "ब", shiftLabel: "न्ह", fontSize: nil, isAction: false, alternates: ["ब्", "बा", "बि", "बी", "बु", "बू", "बृ", "बॄ", "बॢ", "बॣ", "बे", "बै", "बो", "बौ", "बं", "बः"], widthMultiplier: 1.0),
                KeyModel(id: "क", primaryLabel: "क", shiftLabel: "क्ष", fontSize: nil, isAction: false, alternates: ["क्", "का", "कि", "की", "कु", "कू", "कृ", "कॄ", "कॢ", "कॣ", "के", "कै", "को", "कौ", "कं", "कः"], widthMultiplier: 1.0),
                KeyModel(id: "म", primaryLabel: "म", shiftLabel: "ओ", fontSize: nil, isAction: false, alternates: ["म्", "मा", "मि", "मी", "मु", "मू", "मृ", "मॄ", "मॢ", "मॣ", "मे", "मै", "मो", "मौ", "मं", "मः"], widthMultiplier: 1.0),
                KeyModel(id: "ा", primaryLabel: "ा", shiftLabel: "ँ", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "न", primaryLabel: "न", shiftLabel: "म्ह", fontSize: nil, isAction: false, alternates: ["न्", "ना", "नि", "नी", "नु", "नू", "नृ", "नॄ", "नॢ", "नॣ", "ने", "नै", "नो", "नौ", "नं", "नः"], widthMultiplier: 1.0),
                KeyModel(id: "ज", primaryLabel: "ज", shiftLabel: "ज्ञ", fontSize: nil, isAction: false, alternates: ["ज्", "जा", "जि", "जी", "जु", "जू", "जृ", "जॄ", "जॢ", "जॣ", "जे", "जै", "जो", "जौ", "जं", "जः"], widthMultiplier: 1.0),
                KeyModel(id: "व", primaryLabel: "व", shiftLabel: "हृ", fontSize: nil, isAction: false, alternates: ["व्", "वा", "वि", "वी", "वु", "वू", "वृ", "वॄ", "वॢ", "वॣ", "वे", "वै", "वो", "वौ", "वं", "वः"], widthMultiplier: 1.0),
                KeyModel(id: "प", primaryLabel: "प", shiftLabel: "श्र", fontSize: nil, isAction: false, alternates: ["प्", "पा", "पि", "पी", "पु", "पू", "पृ", "पॄ", "पॢ", "पॣ", "पे", "पै", "पो", "पौ", "पं", "पः"], widthMultiplier: 1.0),
                KeyModel(id: "ि", primaryLabel: "ि", shiftLabel: "ी", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "स", primaryLabel: "स", shiftLabel: "अं", fontSize: nil, isAction: false, alternates: ["स्", "सा", "सि", "सी", "सु", "सू", "सृ", "सॄ", "सॢ", "सॣ", "से", "सै", "सो", "सौ", "सं", "सः"], widthMultiplier: 1.0),
                KeyModel(id: "ु", primaryLabel: "ु", shiftLabel: "ू", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0)
            ],
            // ROW 4
            [
                KeyModel(id: "shift", primaryLabel: "⇧", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.5),
                KeyModel(id: "श", primaryLabel: "श", shiftLabel: "अः", fontSize: nil, isAction: false, alternates: ["श्", "शा", "शि", "शी", "शु", "शू", "शृ", "शॄ", "शॢ", "शॣ", "शे", "शै", "शो", "शौ", "शं", "शः"], widthMultiplier: 1.0),
                KeyModel(id: "ह", primaryLabel: "ह", shiftLabel: "ह्म", fontSize: nil, isAction: false, alternates: ["ह्", "हा", "हि", "ही", "हु", "हू", "हृ", "हॄ", "हॢ", "हॣ", "हे", "है", "हो", "हौ", "हं", "हः"], widthMultiplier: 1.0),
                KeyModel(id: "अ", primaryLabel: "अ", shiftLabel: "ऋ", fontSize: nil, isAction: false, alternates: ["अ्", "आ", "इ", "ई", "उ", "ऊ", "ऋ", "ॠ", "ऌ", "ॡ", "ए", "ऐ", "ओ", "औ", "अं", "अः"], widthMultiplier: 1.0),
                KeyModel(id: "ख", primaryLabel: "ख", shiftLabel: "आ", fontSize: nil, isAction: false, alternates: ["ख्", "खा", "खि", "खी", "खु", "खू", "खृ", "खॄ", "खॢ", "खॣ", "खे", "खै", "खो", "खौ", "खं", "खः"], widthMultiplier: 1.0),
                KeyModel(id: "द", primaryLabel: "द", shiftLabel: "त्त", fontSize: nil, isAction: false, alternates: ["द्", "दा", "दि", "दी", "दु", "दू", "दृ", "दॄ", "दॢ", "दॣ", "दे", "दै", "दो", "दौ", "दं", "दः"], widthMultiplier: 1.0),
                KeyModel(id: "ल", primaryLabel: "ल", shiftLabel: "द्व", fontSize: nil, isAction: false, alternates: ["ल्", "ला", "लि", "ली", "लु", "लू", "लृ", "लॄ", "लॢ", "लॣ", "ले", "लै", "लो", "लौ", "लं", "लः"], widthMultiplier: 1.0),
                KeyModel(id: "फ", primaryLabel: "फ", shiftLabel: "ः", fontSize: nil, isAction: false, alternates: ["फ्", "फा", "फि", "फी", "फु", "फू", "फृ", "फॄ", "फॢ", "फॣ", "फे", "फै", "फो", "फौ", "फं", "फः"], widthMultiplier: 1.0),
                KeyModel(id: ",", primaryLabel: ",", shiftLabel: "ौ", fontSize: nil, isAction: false, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "र", primaryLabel: "र", shiftLabel: "रू", fontSize: nil, isAction: false, alternates: ["र्", "रा", "रि", "री", "रु", "रू", "रृ", "रॄ", "रॢ", "रॣ", "रे", "रै", "रो", "रौ", "रं", "रः"], widthMultiplier: 1.0),
                KeyModel(id: "delete", primaryLabel: "⌫", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.5)
            ],
            // ROW 5
            [
                KeyModel(id: "numbers", primaryLabel: "१२३", shiftLabel: nil, fontSize: 18.0, isAction: true, alternates: [], widthMultiplier: 1.5),
                KeyModel(id: "globe", primaryLabel: "🌐", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "emoji", primaryLabel: "😊", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 1.0),
                KeyModel(id: "space", primaryLabel: "", shiftLabel: nil, fontSize: nil, isAction: true, alternates: [], widthMultiplier: 4.0),
                KeyModel(id: "return", primaryLabel: "⏎", shiftLabel: nil, fontSize: 18.0, isAction: true, alternates: [], widthMultiplier: 2.0)
            ]
        ]
    )
    
    static func defaultLayout(for language: KeyboardLanguage) -> KeyboardLayout {
        switch language {
        case .english: return defaultEnglish
        case .nepaliTraditional: return defaultNepali
        }
    }
}
