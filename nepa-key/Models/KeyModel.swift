//
//  KeyModel.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import UIKit

struct KeyModel: Decodable {
    let id: String
    let primaryLabel: String
    let shiftLabel: String?
    let fontSize: CGFloat?
    let isAction: Bool?
    let alternates: [String]
    let widthMultiplier: CGFloat
    
    // The frame will be calculated and cached here by layoutSubviews
    var frame: CGRect = .zero
    
    // Tell the JSONDecoder exactly which keys to look for, ignoring 'frame'
    enum CodingKeys: String, CodingKey {
        case id
        case primaryLabel
        case shiftLabel
        case fontSize
        case isAction
        case alternates
        case widthMultiplier
    }
}
