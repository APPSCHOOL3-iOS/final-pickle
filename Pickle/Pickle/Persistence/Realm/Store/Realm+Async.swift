//
//  Realm+Async.swift
//  Pickle
//
//  Created by 박형환 on 11/5/23.
//

import Foundation
import RealmSwift
import Realm

class DummyRepository {
    let actor: RealmActor
    
    init(actor: RealmActor) {
        self.actor = actor
    }
    
    func create<T: Storable>(_ model: T.Type,
                             data: Data) async throws -> T {
        try await actor.create(model.self, data: data)
    }
    
    func notificationToken<T: Storable>(model: T.Type,
                                        id: String,
                                        keyPath: [PartialKeyPath<T>])
    async throws -> RNotificationToken where T: RObject {
        return try await actor.notificationToken(model, id: id, keyPaths: [], { _ in
            
        })
    }
}

actor RealmActor {
    var realm: Realm!
    
    init(type: RealmStore.RealmType) async throws {
        realm = try await RealmProvider.actorRealm(actor: self,
                                                   type: type)
    }
    
    func close() {
        realm = nil
    }
}

extension RealmActor {
    
    func create<T: Storable>(_ model: T.Type,
                             data: Data) async throws -> T {
        return try await realm.asyncWrite {
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            guard let model = model as? RObject.Type else { throw RealmError.notRealmObject }
            let value = self.realm.create(model, value: json)
            return value as! T
        }
    }
    
    func save<T: Storable>(object: T) async throws {
        return try await realm.asyncWrite {
            guard let object = object as? RObject else { throw RealmError.notRealmObject }
            realm.add(object)
        }
    }
    
    func update(object: Storable) async throws {
        try await realm.asyncWrite {
            guard let object = object as? RObject else { throw RealmError.notRealmObject }
            realm.add(object, update: .modified)
        }
    }
    
    func update<T: Storable>(_ model: T.Type,
                             id: String,
                             item: T,
                             query: ((Query<T>) -> Query<Bool>)) async throws -> T where T: RObject {
        try await realm.asyncWrite {
            let results = realm.objects(model).where(query)
            if results.count == 1 {
                return realm.create(model, value: item, update: .modified)
            } else {
                throw RealmError.updateMustOneValue
            }
        }
    }
    
    func fetch<T>(_ model: T.Type,
                  query: ((Query<T>) -> Query<Bool>)?,
                  sorted: Sorted?) async throws -> [T] where T: Storable, T: RObject {
        
        // MARK: asyncRefresh() can only be called on main thread or actor-isolated Realms
        await realm.asyncRefresh()
        
        if let query {
            return realm.objects(model).where(query).map { $0 }
        } else {
            return realm.objects(model).map { $0 }
        }
    }
    
    /// Delete Model 메타타입 과 id를 받아서 delete할 오브젝트를 골라 삭제한다.
    /// - Parameters:
    ///   - model: 삭제할 모델의 메타타입
    ///   - id: Primary id
    func delete<T: Storable>(model: T.Type, id: String) async throws {
        try await realm.asyncWrite {
            guard let model = model as? RObject.Type else { throw RealmError.notRealmObject }
            if let value = realm.object(ofType: model, forPrimaryKey: id) {
                realm.delete(value)
            } else {
                throw RealmError.deleteFailed
            }
        }
    }
    
    func deleteAll<T: Storable>(_ model: T.Type) async throws where T: RObject {
        try await realm.asyncWrite {
            let objects = realm.objects(model)
            for object in objects {
                realm.delete(object)
            }
        }
    }
    
    func notificationToken<T: Storable>(_ model: T.Type,
                                        id: String,
                                        keyPaths: [PartialKeyPath<T>],
                                        _ completion: @escaping ObjectCompletion<T>)
    async throws -> NotificationToken
    where T: RObject {
        let object = realm.object(ofType: model, forPrimaryKey: id)
        guard let object else { throw RealmError.invalidObjectORPrimaryKey }
        return object.observe(keyPaths: keyPaths, completion)
    }
}
