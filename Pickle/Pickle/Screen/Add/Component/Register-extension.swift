//
//  Register-extension.swift
//  Pickle
//
//  Created by 박형환 on 11/20/23.
//

import SwiftUI

// MARK: Register PickerView extension
extension RegisterView {
    
    var timeConstraint: ClosedRange<Date> {
        let value = Date().format("yyyy-MM-dd-HH-mm")
        
        let dates = value.split(separator: "-").map { Int(String($0))! }
        let start: DateComponents = DateComponents(timeZone: TimeZone(identifier: "KST"),
                                                   year: dates[safe: 0],
                                                   month: dates[safe: 1],
                                                   day: dates[safe: 2],
                                                   hour: dates[safe: 3],
                                                   minute: dates[safe: 4])
        let end: DateComponents = DateComponents(timeZone: TimeZone(identifier: "KST"),
                                                 year: dates[safe: 0],
                                                 month: dates[safe: 1],
                                                 day: dates[safe: 2],
                                                 hour: 23,
                                                 minute: 59)
        return PickerView.constraint(start: start,
                                     end: end)
    }
    
    func datePickerGenerator(startTimes: Binding<Date>, show: Binding<Bool>) -> some View {
        PickerView(showTimeMissionModal: show,
                   changedWakeupTime: startTimes,
                   title: "오늘 할일 시간",
                   action: { show.wrappedValue.toggle() },
                   closedRange: timeConstraint)
    }
    
    func targetTimePickerViewGenerator(targetTimes: Binding<String>,
                                       show: Binding<Bool>,
                                       targetTimeUnitStrs: [String]) -> some View {
       TimeUnitPickerView(targetTimes: targetTimes,
                          show: show,
                          targetTimeUnitStrs: targetTimeUnitStrs)
    }
}
