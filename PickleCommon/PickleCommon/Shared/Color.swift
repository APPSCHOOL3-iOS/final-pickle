//
//  Color.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

public extension Color {
    // 연한 회색
    static var lightGray: Color {
        return Color(hex: 0xFAFAFA)
    }
    
    // 진한 회색
    static var darkGray: Color {
        return Color(hex: 0x1C1C1E)
    }
    
    // 디폴트 회색
    static var defaultGray: Color {
        return Color(hex: 0xCCCCCC)
    }
    
    // 글씨용 진한 회색
    static var textGray: Color {
        return Color(hex: 0x707072)
    }
    
    static var pickle: Color {
        return Color.init(hex: 0x359059)
    }
    
    static var mainRed: Color {
        return Color.init(hex: 0xE62E2E)
    }
    
    static var pepperoniRed: Color {
        return Color.init(hex: 0xFF4145)
    }

}

public extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}
