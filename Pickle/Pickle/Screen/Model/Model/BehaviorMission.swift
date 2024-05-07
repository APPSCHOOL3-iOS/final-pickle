//
//  BehaviorMission.swift
//  Pickle
//
//  Created by 박형환 on 11/13/23.
//

import Foundation

struct BehaviorMission: Mission, Identifiable {
    let id: String
    let title: String
    var status: MissionStatus
    var status1: MissionStatus
    var status2: MissionStatus
    var date: Date  // 투두 생성 날짜,시간
    
    init(id: String = UUID().uuidString,
         title: String = "걷기 미션",
         status: MissionStatus = .ready,
         status1: MissionStatus = .ready,
         status2: MissionStatus = .ready,
         date: Date = Date()) {
        self.id = id
        self.title = title
        self.status = status
        self.status1 = status1
        self.status2 = status2
        self.date = date
    }
}
extension BehaviorMission: Equatable { }
