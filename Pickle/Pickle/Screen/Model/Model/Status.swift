//
//  Status.swift
//  Pickle
//
//  Created by 박형환 on 10/18/23.
//

import Foundation

public typealias TodoStatus = Status
public typealias MissionStatus = Status

public enum Status: String, Codable {
    // 진행전 진행중 완료 포기
    case ready
    case ongoing
    case complete
    case done
    case giveUp
    case fail
    
    var value: String {
        self.rawValue
    }
    
    var string: String {
        switch self {
        case .ready:
            return "아직"
        case .ongoing:
            return "진행중"
        case .complete:
            return "성공"
        case .done:
            return "완료"
        case .giveUp:
            return "포기"
        case .fail:
            return "실패"
        }
    }
}
