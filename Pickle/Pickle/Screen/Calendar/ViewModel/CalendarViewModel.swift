//
//  CalendarViewModel.swift
//  Pickle
//
//  Created by kaikim on 2023/09/25.
//

import SwiftUI
import PickleCommon

class CalendarViewModel: ObservableObject {

    // MARK: - Current Week Days
    @Published var currentWeek: [Date] = []
    
    // MARK: - Current Month
    // @Published var currentMonth: [Date.MonthDate] = []
    
    // MARK: - Current Day
    @Published var currentDay: Date = Date()
    
    // MARK: - Updating current Month/Week
    @Published var currentMonthIndex: Int = 0
    @Published var currentWeekIndex: Int = 0
    
    init() {
        fetchCurrentWeek(date: currentDay)
    }
    
    // MARK: Fetching Week Based on given Date
    
    func fetchCurrentWeek(date: Date) {
        currentWeek.removeAll()
        let calendar = Calendar.autoupdatingCurrent
        let startOfDate = calendar.startOfDay(for: date)
        
        let weekForDate = calendar.dateInterval(of: .weekOfMonth, for: startOfDate)
        
        guard let firstWeekDay = weekForDate?.start else {
            return
        }
        (0...6).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: - Get current Month Date
    func getCurrentMonth() -> Date {
        
        let calendar = Calendar.autoupdatingCurrent
        
        guard let currentMonth =  calendar.date(byAdding: .month, value: currentMonthIndex, to: Date()) else { return Date() }
        
        return currentMonth
    }
    
    // MARK: - Get current Month
    func extractMonth() -> [MonthDate] {
        let calendar = Calendar.autoupdatingCurrent
        
        let currentMonth = getCurrentMonth()
        
        var resultMonth = currentMonth.fetchMonth().compactMap { date -> MonthDate in
            let day = calendar.component(.day, from: date)
            let resultDay = MonthDate(day: day, date: date)
            return resultDay
            
        }
        
        let firstWeekDay = calendar.component(.weekday, from: resultMonth.first?.date ?? Date())
        
        for _ in 0..<firstWeekDay - 1 {
            resultMonth.insert(MonthDate(day: -1, date: Date()), at: 0)
        }
        return resultMonth
    }
    
    // MARK: - checking if current date is today or not
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: - Checking ifthe currentHour is task Hour
    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        return hour == currentHour
    }
    
    // MARK: - Creating Next Week, based on the Last Current Week's Date
    func createNextWeek() {
        currentWeek.removeAll()
        let calendar = Calendar.autoupdatingCurrent
        let startOfLastDate = calendar.startOfDay(for: currentDay)
        guard let nextDate = calendar.date(byAdding: .day, value: 7 * currentWeekIndex, to: startOfLastDate) else { return }
        
        return fetchCurrentWeek(date: nextDate)
        
    }
    
    // MARK: - Creating Previous Week, based on the First Current Week's Date
    func createPreviousWeek() {
        currentWeek.removeAll()
        let calendar = Calendar.autoupdatingCurrent
        let startOfFirstDate = calendar.startOfDay(for: currentDay)
        guard let previousDate = calendar.date(byAdding: .day, value: 7 * currentWeekIndex, to: startOfFirstDate) else { return }
        
        return fetchCurrentWeek(date: previousDate)
        
    }
    
    func resetForTodayButton() {
        currentMonthIndex = 0
        currentWeekIndex = 0
        currentDay = Date()
        fetchCurrentWeek(date: currentDay)
    }
}
