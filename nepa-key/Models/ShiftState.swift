//
//  ShiftState.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

enum ShiftState {
    case lowercased
    case uppercased // Shift tapped once (reverts after one letter)
    case capsLocked // Shift double-tapped (stays uppercase)
}
