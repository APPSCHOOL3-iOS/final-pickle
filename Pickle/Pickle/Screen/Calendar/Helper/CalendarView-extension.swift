//
//  ClendarView+extension.swift
//  Pickle
//
//  Created by 박형환 on 11/9/23.
//

import SwiftUI

extension CalendarView {
    enum Routing: Hashable, Identifiable {
        var id: Self {
            return self
        }
        case calendar
    }
}

extension View {
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
        
    }
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
        
    }
    
    // MARK: - Checking Two dates are same
    func isSameDate(_ date1: Date, date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}
