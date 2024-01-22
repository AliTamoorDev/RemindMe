//
//  Sounds.swift
//  RemindMe
//
//  Created by Ali Tamoor on 16/01/2024.
//

import Foundation

// Enum to set different sounds for scheduling a reminder
enum Sounds: String, Codable, CaseIterable {
    case autumnWind = "Autumn Wind"
    case hellSing = "Happy Day"
    case jollyRing = "Conventional"
    case secondAttempt = "Victory"
    case jb = "Johnny Bravo"
//    case fest = "Festival"
    
    var stringValue: String {
        switch self {
        case .autumnWind: return "autumnWind"
        case .hellSing: return "hellSing"
        case .jollyRing: return "jollyRing"
        case .secondAttempt: return "secondAttempt"
        case .jb: return "JB"
//        case .fest: return "fest"
        }
    }
}
