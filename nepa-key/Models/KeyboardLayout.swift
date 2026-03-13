//
//  KeyboardLayout.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

struct KeyboardLayout: Decodable {
    let languageCode: String
    var rows: [[KeyModel]]
}
