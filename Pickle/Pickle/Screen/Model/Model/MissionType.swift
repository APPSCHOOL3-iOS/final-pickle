//
//  MissionType.swift
//  Pickle
//
//  Created by 박형환 on 10/9/23.
//

import Foundation

enum MissionType {
    case time(TimeMission)
    case behavior(BehaviorMission)
    
    var anyMission: any Mission {
        switch self {
        case .time(let timeMission):
            return timeMission
        case .behavior(let behaviorMission):
            return behaviorMission
        }
    }
    
    var type: MissionRepositoryType {
        switch self {
        case .time:
            return .time
        case .behavior:
            return .behavior
        }
    }
}

enum MissionRepositoryType {
    case time
    case behavior
    case none
}
