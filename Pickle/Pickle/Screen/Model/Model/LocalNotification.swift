//
//  LocalNotification.swift
//  Pickle
//
//  Created by 최소정 on 10/10/23.
//

import Foundation

enum NotiType {
    case calendar   // 특정 날짜 및 시간에 알림
    case todo(Todo)
    case time       // 몇 초 후 알림
    case health
    case wakeUp
    
    static func getValue(value: String) -> Self {
        switch value {
        case "calendar":
            return .calendar
        case "todo":
            return .todo(Todo.sample)
        case "time":
            return .time
        case "health":
            return .health
        case "wakeUp":
            return .wakeUp
        default:
            return .calendar
        }
    }
    
    var value: String {
        switch self {
        case .calendar:
            return "calendar"
        case .todo:
            return "todo"
        case .time:
            return "time"
        case .health:
            return "health"
        case .wakeUp:
            return "wakeUp"
        }
    }
}

struct LocalNotification {
    var identifier: String
    var title: String
    var body: String
    var dateComponents: DateComponents?
    var timeInterval: Double?
    var repeats: Bool
    var userInfo: [String: Any] = [:]
    var type: NotiType
}

extension LocalNotification {
    static let notiType: String = "notificationType"
    static let status: String = "status"
    static let currentDate = Date()
    static let _title: String = "현실도 피자"
    
    static var timer: Self {
        LocalNotification(identifier: UUID().uuidString,
                          title: "현실도 피자",
                          body: "목표시간이 완료됐어요!",
                          timeInterval: 1,
                          repeats: false,
                          type: .time)
    }
    
    static func makeLocalNotification(_ item: Todo,
                                      notification type: NotiType,
                                      before time: Int = 3) -> Self {
       
        let date = item.startTime.adding(minutes: -time)
        let dateComp = Calendar.current.dateComponents([.hour, .minute], from: date )
        let body = "\(item.content) 시작 \(time)분전이에요"
        
        var info: [String: Any] = item.asDictionary
        info[status] = item.status.rawValue
        info[notiType] = type.value
        
        let timeDifference = date.timeIntervalSince(currentDate)
        let body2 = "\(item.content) 시작할 시간이에요"

        if timeDifference > 180 {
            return .init(identifier: item.id,
                         title: _title,
                         body: body,
                         dateComponents: dateComp,
                         repeats: false,
                         userInfo: info,
                         type: type)
        }
        return .init(identifier: item.id,
                     title: _title,
                     body: body2,
                     dateComponents: Calendar.current.dateComponents([.hour, .minute], from: Date().adding(minutes: 1)),
                     repeats: false,
                     userInfo: info,
                     type: type)
    }
}
