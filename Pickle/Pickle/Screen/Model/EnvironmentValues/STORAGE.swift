//
//  Env.swift
//  Pickle
//
//  Created by 박형환 on 5/8/24.
//

import Foundation

enum STORAGE: String {
    case backgroundNumber
    case isRunTimer
    case todoId
    case onboarding
    case systemTheme
    case is24HourClock
    case timeFormat
    
    var id: String {
        self.rawValue
    }
}
