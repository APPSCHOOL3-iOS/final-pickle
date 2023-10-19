//
//  TodoStore.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import SwiftUI

//                              UserRepository                                            CoreData
// TodoStore --->-protocol-<-- TodoRepository ---상속---> BaseRepository --->protocol <--- RealmStore (입출력)
// MissionStore               MissionRepository                                           FireStore

@MainActor
final class MissionStore: ObservableObject {
    
    @Published var timeMissions: [TimeMission] = []
    @Published var behaviorMissions: [BehaviorMission] = []
    
    @Injected(TimeRepoKey.self) var timeMissionRepository: any TimeRepositoryProtocol
    @Injected(BehaviorRepoKey.self) var behaviorMissionRepository: any BehaviorRepositoryProtocol
    
    // MARK: 1안 그냥 되는대로 하다가 나중에 생각한다. 너무 처음부터 빡세게 생각하는것 같다.
    // MARK: 2안 enum으로 그냥 한다.
    // MARK: 3안 mediator ?
    // MARK: 4안 command를 딕셔너리로 ?
    // MARK: 5안 store(viewModel)를 쪼갠다
    func fetch() -> ([TimeMission], [BehaviorMission]) {
        let _timeMissions = timeMissionRepository.fetch(sorted: Sorted.missionAscending)
        let _behaviorMissions = behaviorMissionRepository.fetch(sorted: Sorted.missionAscending)
        // self.timeMissions = _timeMissions
        // self.behaviorMissions = _behaviorMissions
        return (_timeMissions, _behaviorMissions)
    }
    
    func add(mission: MissionType) {
        switch mission {
        case .time(let timeMission):
            timeMissionRepository.save(model: timeMission)
        case .behavior(let behaviorMission):
            behaviorMissionRepository.save(model: behaviorMission)
        }
    }
    
    func delete(mission: MissionType) {
        switch mission {
        case .time(let timeMission):
            timeMissionRepository.delete(model: timeMission)
        case .behavior(let behaviorMission):
            behaviorMissionRepository.delete(model: behaviorMission)
        }
    }
    
    /// 전체 목록 Delete
    /// - Parameter todo: todo Struct
    func deleteAll(mission: MissionType) {
        switch mission {
        case .time(_):
            timeMissionRepository.deleteAll()
        case .behavior(_):
            behaviorMissionRepository.deleteAll()
        }
    }
    
    func update(mission: MissionType) {
        switch mission {
        case .time(let timeMission):
            timeMissionRepository.update(model: timeMission)
        case .behavior(let behaviorMission):
            behaviorMissionRepository.update(model: behaviorMission)
        }
    }
    
    /// 빈 모델 생성
    func create(mission: MissionType) {
        switch mission {
        case .time(_):
            timeMissionRepository.create { _ in }
        case .behavior(_):
            behaviorMissionRepository.create { _ in }
        }
    }
}
