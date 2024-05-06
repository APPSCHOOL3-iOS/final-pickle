//
//  Mission.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/26.
//

import Foundation

protocol Mission: MappableProtocol {
    var id: String { get }
    var title: String { get }
    var status: MissionStatus { get }
    var date: Date { get }
}

struct TimeMission: Mission, Identifiable {
    let id: String
    let title: String
    var status: MissionStatus
    var date: Date // 타임미션 생성 날짜,시간 -> 생성날짜와 지금 날짜 비교해서 초기화할 때 쓸 것
    var wakeupTime: Date // 기상 목표 시간
    
    init(id: String, title: String = "", status: MissionStatus = .ready, date: Date = Date(), wakeupTime: Date = Date()) {
        self.id = id
        self.title = title
        self.status = status
        self.date = date
        self.wakeupTime = wakeupTime
    }
}

struct BehaviorMission: Mission, Identifiable {
    let id: String
    let title: String
    var status: MissionStatus
    var status2: MissionStatus
    var status3: MissionStatus
    var date: Date  // 투두 생성 날짜,시간
    
    init(id: String,
         title: String = "",
         status: MissionStatus = .ready,
         status2: MissionStatus = .ready,
         status3: MissionStatus = .ready,
         date: Date = Date()) {
        self.id = id
        self.title = title
        self.status = status
        self.status2 = status2
        self.status3 = status3
        self.date = date
    }
}

extension TimeMission {
    typealias PersistenceType = TimeMissionObject
    
    func mapToPersistenceObject() -> TimeMissionObject {
        if let id = UUID(uuidString: self.id) {
            return TimeMissionObject(title: self.title,
                                     status: .init(rawValue: self.status.value) ?? .ready,
                                     date: self.date,
                                     wakeupTime: self.wakeupTime)
        } else {
            return TimeMissionObject(id: self.id,
                                     title: self.title,
                                     status: .init(rawValue: self.status.value) ?? .ready,
                                     date: self.date,
                                     wakeupTime: self.wakeupTime)
        }
    }
    
    static func mapFromPersistenceObject(_ object: TimeMissionObject) -> TimeMission {
        TimeMission(id: object.id.stringValue,
                    title: object.title,
                    status: .init(rawValue: object.status.rawValue) ?? .ready,
                    date: object.date,
                    wakeupTime: object.wakeupTime)
    }
}

extension BehaviorMission {
    typealias PersistenceType = BehaviorMissionObject
    
    func mapToPersistenceObject() -> BehaviorMissionObject {
        if let id = UUID(uuidString: self.id) {
            return BehaviorMissionObject(title: self.title,
                                         status: .init(rawValue: self.status.value) ?? .ready,
                                         date: self.date)
        } else {
            return BehaviorMissionObject(id: self.id,
                                         title: self.title,
                                         status: .init(rawValue: self.status.value) ?? .ready,
                                         date: self.date)
        }
    }
    
    static func mapFromPersistenceObject(_ object: BehaviorMissionObject) -> BehaviorMission {
        BehaviorMission(id: object.id.stringValue,
                        title: object.title,
                        status: .init(rawValue: object.status.rawValue) ?? .ready,
                        date: object.date)
    }
}
