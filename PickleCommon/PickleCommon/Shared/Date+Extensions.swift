//
//  Date+Extensions.swift
//  Pickle
//
//  Created by kaikim on 2023/09/26.
//

import SwiftUI

public typealias MonthDate = Date.MonthDate

public extension Date {
    
    static let formatter = DateFormatter()
    
    // MARK: - Custom Date Format
    func format(_ format: String) -> String {
        Date.formatter.dateFormat = format
        Date.formatter.locale = Locale(identifier: "ko_KR")
        Date.formatter.timeZone = TimeZone(identifier: "KST")
        return Date.formatter.string(from: self)

    }
    
    struct MonthDate: Identifiable, Hashable {
        public var id = UUID().uuidString
        public var day: Int
        public var date: Date
        public init(id: String = UUID().uuidString, day: Int, date: Date) {
            self.id = id
            self.day = day
            self.date = date
        }
    }
    
    // MARK: - Checking whether the Date is Today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isSameHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedSame
    }
    
    var isPastHour: Bool {
        return Calendar.current.compare(self, to: .init(), toGranularity: .hour) == .orderedAscending
    }
    
    /// '분' 더하는 메소드
    /// - Parameter minutes: 분
    /// - Returns: 더해진 날짜
    func adding(minutes: Int) -> Date {
        let date = Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
        let formatter = Date.formatter
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = NSTimeZone(name: "ko_KR") as? TimeZone
        let str = formatter.string(from: date)
        return formatter.date(from: str)!
    }
    
    // MARK: - CalenderViewModel -> 월 달력 Month Fetch를 위한 함수
    func fetchMonth() -> [Date] {
        let calendar = Calendar.autoupdatingCurrent
        guard let startDate = calendar.date(from: Calendar.autoupdatingCurrent.dateComponents([.year, .month], from: self)) else { return [] }
        guard let range = calendar.range(of: .day, in: .month, for: startDate) else { return [] }

        return range.compactMap { day -> Date in
            
            guard let month = calendar.date(byAdding: .day, value: day - 1, to: startDate) else { return Date() }
            return month
        }
    }
    
    static func convertSecondsToTime(timeInSecond: TimeInterval) -> String {
        let hours: Int = Int(timeInSecond / 3600)
        let minutes: Int = Int(timeInSecond - Double(hours) * 3600) / 60
        let seconds: Int = Int(timeInSecond.truncatingRemainder(dividingBy: 60))
        
        if timeInSecond >= 3600 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    static func convertTargetTimeToString(timeInSecond: TimeInterval) -> String {
        let hours: Int = Int(timeInSecond / 3600)
        let minutes: Int = Int(timeInSecond - Double(hours) * 3600) / 60
        
        if timeInSecond >= 3600 {
            return String(format: "%i시간 %i분", hours, minutes)
        } else {
            return String(format: "%i분", minutes)
        }
    }
}
