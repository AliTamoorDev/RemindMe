//
//  Sounds.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import Foundation

enum Sounds: String, CaseIterable {
    case autumnWind = "Autumn Wind"
    case hellSing = "Hell Sing"
    case JollyRing = "Happy Day"
    case secondAttempt = "Second Attempt"
    case jb = "JB"
    
    var stringValue: String {
        switch self {
        case .autumnWind: return "autumnWind"
        case .hellSing: return "hellSing"
        case .JollyRing: return "jollyRing"
        case .secondAttempt: return "secondAttempt"
        case .jb: return "JB"
        }
    }
}
