//
//  MissionRepository.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import Foundation

protocol MissionRepositoryProtocol: Dependency, AnyObject {
    associatedtype DTO: Mission
    associatedtype Persited: MissionObject
    
    func fetch(sorted: Sorted) -> [DTO]
    func fetch(sorted: Sorted) async -> [DTO]  // do not use this method
    func save<T>(model: T) where T: Mission
    func update(model: DTO)
    func delete(model: DTO)
    func deleteAll()
    
    func notification(id: String,
                      keyPaths: [PartialKeyPath<Persited>],
                      _ completion: @escaping (DTO) -> Void) throws -> RNotificationToken
}

protocol TimeRepositoryProtocol: MissionRepositoryProtocol where DTO == TimeMission, Persited == TimeMissionObject { }
protocol BehaviorRepositoryProtocol: MissionRepositoryProtocol where DTO == BehaviorMission, Persited == BehaviorMissionObject { }

final class TimeMissionRepository: BaseRepository<TimeMissionObject>, TimeRepositoryProtocol {
    
    typealias DTO = TimeMission
    typealias Persisted = TimeMissionObject
    
    func save<T>(model: T) where T: Mission {
        let persistent = model.mapToPersistenceObject()
        do {
            guard let data = persistent as? Persisted else { throw MissionError.castingError }
            try super.save(object: data)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func fetch(sorted: Sorted) -> [TimeMission] {
        do {
            let missionObject = try super.fetch(TimeMissionObject.self, predicate: nil, sorted: Sorted(key: "date", ascending: true))
            let results = missionObject.map { TimeMission.mapFromPersistenceObject($0) }
            return results
        } catch {
            assert(false)
            Log.error(error.localizedDescription)
        }
        return []
    }
    
    func fetch(sorted: Sorted) async -> [TimeMission] {
        await withCheckedContinuation { continuation in
            super.fetch(TimeMissionObject.self, predicate: nil, sorted: Sorted(key: "date", ascending: true)) { missions in
                let results = missions.map { TimeMission.mapFromPersistenceObject($0) }
                continuation.resume(returning: results)
            }
        }
    }
    
    func save(model: TimeMission) {
        let persistent = model.mapToPersistenceObject()
        do {
            try super.save(object: persistent)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func update(model: TimeMission) {
        let persistent = model.mapToPersistenceObject()
        do {
            try super.update(object: persistent)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func delete(model: TimeMission) {
        let persistent = model.mapToPersistenceObject()
        do {
            try super.delete(object: persistent, id: persistent.id)
        } catch {
            Log.error("error: occur: \(error)")
        }
    }
    
    func deleteAll() {
        do {
            try super.deleteAll(TimeMissionObject.self)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func notification(id: String,
                      keyPaths: [PartialKeyPath<TimeMissionObject>],
                      _ completion: @escaping (TimeMission) -> Void)
    throws -> RNotificationToken {
        
        let objectCompletion: ObjectCompletion<TimeMissionObject> = { change in
            switch change {
            case .change(let object, let properties):
                Log.error("timeMIssion Properties : \(properties)")
                let timeMission = TimeMission.mapFromPersistenceObject(object)
                completion(timeMission)
            case .error(let error):
                 Log.error("error Occur : \(error)")
            default:
                break
            }
        }
        return try super.dbStore.notificationToken(TimeMissionObject.self,
                                            id: id,
                                            keyPaths: keyPaths,
                                            objectCompletion)
    }
}
