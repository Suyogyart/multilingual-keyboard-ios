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
        languageCode: "en-US",
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
                KeyModel(id: "globe", primaryLabel: "🌐", shiftLabel: nil, fontSize: nil, isAction: true, alternates: ["ब", "क", "म", "ा", "न", "ज", "ब", "क", "म", "ा", "न", "ज"], widthMultiplier: 1.0),
                KeyModel(id: "space", primaryLabel: "", shiftLabel: nil, fontSize: nil, isAction: false, alternates: [], widthMultiplier: 5.0),
                KeyModel(id: "return", primaryLabel: "⏎", shiftLabel: nil, fontSize: 18.0, isAction: true, alternates: [], widthMultiplier: 2.0)
            ]
        ]
    )
}
