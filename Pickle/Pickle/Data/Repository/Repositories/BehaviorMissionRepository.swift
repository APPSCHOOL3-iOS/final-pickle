//
//  BehaviorMissionRepository.swift
//  Pickle
//
//  Created by 박형환 on 10/6/23.
//

import Foundation

final class BehaviorMissionRepository: BaseRepository<BehaviorMissionObject>, BehaviorRepositoryProtocol {
    typealias DTO = BehaviorMission
    typealias Persisted = BehaviorMissionObject
    
    func fetch(sorted: Sorted) async -> [BehaviorMission] {
        await withCheckedContinuation { continuation in
            super.fetch(BehaviorMissionObject.self, predicate: nil, sorted: Sorted(key: "date", ascending: true)) { missions in
                let results = missions.map { BehaviorMission.mapFromPersistenceObject($0) }
                continuation.resume(returning: results)
            }
        }
    }
    
    func fetch(sorted: Sorted) -> [BehaviorMission] {
        do {
            let behaviorMissionObject = try super.fetch(BehaviorMissionObject.self, predicate: nil, sorted: Sorted(key: "date", ascending: true))
            let results = behaviorMissionObject.map { BehaviorMission.mapFromPersistenceObject($0) }
            return results
        } catch {
            Log.error("error \(error)")
        }
        return []
    }
    
    func create(item: BehaviorMission, _ completion: @escaping (BehaviorMissionObject) -> Void) {
        let object = item.mapToPersistenceObject()
        do {
            try super.create(BehaviorMissionObject.self, item: object, completion: completion)
        } catch {
            Log.error("error occur : \(error)")
        }
    }
    
    func save<T>(model: T) where T: Mission {
        let persistent = model.mapToPersistenceObject()
        do {
            guard let data = persistent as? Persisted else { throw MissionError.castingError }
            try super.save(object: data)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func update(model: BehaviorMission) {
        let persistent = model.mapToPersistenceObject()
        do {
            try super.update(object: persistent)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func delete(model: BehaviorMission) {
        let persistent = model.mapToPersistenceObject()
        do {
            try super.delete(object: persistent, id: persistent.id)
        } catch {
            Log.error("error: occur: \(error)")
        }
    }
    
    func deleteAll() {
        do {
            try super.deleteAll(BehaviorMissionObject.self)
        } catch {
            Log.error("error occur: \(error)")
        }
    }
    
    func notification(id: String,
                      keyPaths: [PartialKeyPath<BehaviorMissionObject>],
                      _ completion: @escaping (BehaviorMission) -> Void)
    throws -> RNotificationToken {
        
        let objectCompletion: ObjectCompletion<BehaviorMissionObject> = { change in
            switch change {
            case .change(let object, _):
                let behavior = BehaviorMission.mapFromPersistenceObject(object)
                completion(behavior)
            case .error(let error):
                Log.error("error Occur : \(error)")
            default:
                break
            }
        }
        
        return try super.dbStore.notificationToken(BehaviorMissionObject.self,
                                                   id: id,
                                                   keyPaths: keyPaths,
                                                   objectCompletion)
    }
}
