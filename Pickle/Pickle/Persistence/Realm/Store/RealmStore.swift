//
//  RealmStore.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import SwiftUI
import RealmSwift
import Combine
import Realm

typealias RealmFilter<T: Storable> = (Query<T>) -> Query<Bool>

typealias RObjectBase = ObjectBase
typealias ObjectCompletion<T> = (ObjectChange<T>) -> Void
typealias RNotificationToken = NotificationToken
typealias RObject = RealmSwiftObject

final class RealmStore: DBStore {
    
    enum RealmType {
        case disk
        case inmemory
    }
    
    var realmStore: Realm! {
        switch type {
        case .disk:
            return RealmProvider.defaultRealm
        case .inmemory:
            return RealmProvider.previewRealm
        }
    }
    
    private var type: RealmType
    
    init(type: RealmType = .disk) {
        self.type = type
    }
    
    static var previews: RealmStore = RealmStore(type: .inmemory)
    
    func create<T>(_ model: T.Type,
                   data: Data,
                   completion: @escaping (T) -> Void) throws where T: Storable {
        
        let realm = realmStore!
        guard let model = model as? RObject.Type else { throw RealmError.notRealmObject }
        
        try realm.write {
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            let value = realm.create(model, value: json)
            completion(value as! T)
        }
    }
    
    func create<T>(_ model: T.Type,
                   item: T,
                   completion: @escaping (T) -> Void) throws where T: Storable {
        
        let realm = realmStore!
        guard let model = model as? Object.Type else { throw RealmError.notRealmObject }
        try realm.write {
            let type = realm.create(model, value: item)
            completion(type as! T)
        }
    }
    
    func save(object: Storable) throws {
        let realm = realmStore!
        guard let object = object as? RObject else { throw RealmError.notRealmObject }
        try realm.write {
            realm.add(object)
        }
    }
    
    func update(object: Storable) throws {
        let realm = realmStore!
        guard let object = object as? RObject else { throw RealmError.notRealmObject }
        try realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    func update<T>(_ model: T.Type,
                   item: T,
                   query: ((Query<T>) -> Query<Bool>)?) throws -> T where T: Storable, T: RObject {
        let realm = realmStore!
        return try realm.write {
            if let query {
                let results = realm.objects(model).where(query)
                if results.count == 1 {
                    return realm.create(model, value: item, update: .modified)
                } else {
                    throw RealmError.updateMustOneValue
                }
            } else {
                return realm.create(model, value: item, update: .modified)
            }
        }
    }
    
    /// Delete Model 메타타입 과 id를 받아서 delete할 오브젝트를 골라 삭제한다.
    /// - Parameters:
    ///   - model: 삭제할 모델의 메타타입
    ///   - id: Primary id
    func delete<T>(model: T.Type, id: String) throws {
        guard
            let realm = realmStore,
            let model = model as? Object.Type
        else {
            throw RealmError.notRealmObject
        }
        try realm.write {
            if let value = realm.object(ofType: model, forPrimaryKey: id) {
                realm.delete(value)
            } else {
                throw RealmError.deleteFailed
            }
        }
    }
    
    func deleteAll<T>(_ model: T.Type) throws where T: Storable {
        guard
            let realm = realmStore,
            let model = model as? RObject.Type
        else {
            throw RealmError.notRealmObject
        }
        try realm.write {
            let objects = realm.objects(model)
            for object in objects {
                realm.delete(object)
            }
        }
    }
    
    func fetch<T>(_ model: T.Type,
                  predicate: NSPredicate?,
                  sorted: Sorted?) throws -> [T] where T: Storable {
        let realm = realmStore!
        guard let model = model as? RObject.Type else { throw RealmError.notRealmObject }
        var objects = realm.objects(model)
        
        if let predicate = predicate {
            objects = objects.filter(predicate)
        }
        
        if let sorted {
            objects = objects.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        return objects.compactMap { $0 as? T }
    }
    
    func notificationToken<T>(_ model: T.Type,
                              id: String,
                              keyPaths: [PartialKeyPath<T>],
                              _ completion: @escaping ObjectCompletion<T>) throws 
    -> NotificationToken where T: Storable, T: ObjectBase {
        let realm = realmStore!
        guard let model = model as? RObject.Type else { throw RealmError.notRealmObject }
        let object = realm.object(ofType: model, forPrimaryKey: id)
        guard let object else { throw RealmError.invalidObjectORPrimaryKey }
        return object.observe(keyPaths: keyPaths, completion)
    }
    
    func fetch<T>(_ model: T.Type,
                  filtered: RealmFilter<T>,
                  sorted: Sorted?) throws -> [T] where T: Storable, T: RObject {
        let realm = realmStore!
        var objects = realm.objects(model).where(filtered)
        if let sorted {
            objects = objects.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        return objects.map { $0 }
    }
    
    func fetch<T>(_ model: T.Type,
                  predicate: NSPredicate?,
                  sorted: Sorted?,
                  complection: ([T]) -> Void) throws where T: Storable {
        let realm = realmStore!
        guard let model = model as? RObject.Type else { throw RealmError.notRealmObject }
        var objects = realm.objects(model)
        if let predicate = predicate {
            objects = objects.filter(predicate)
        }
        if let sorted {
            objects = objects.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        complection(objects.compactMap { $0 as? T })
    }
}

extension RealmStore: Dependency {}

struct Sorted {
    var key: String
    var ascending: Bool = true
}
extension Sorted {
    static var missionAscending: Self {
        Sorted(key: "date", ascending: true)
    }
    
    static var missionDscending: Self {
        Sorted(key: "date", ascending: false)
    }
    
    static var createdAscending: Self {
        Sorted(key: "createdAt", ascending: true)
    }
}

//  let objects = realm.objects(PizzaObject.self)
//  pizzaTOken = objects.observe(keyPaths: [\.lock], { pizzaob in
//      switch pizzaob {
//      case .update(let pizza,
//                   deletions: let deletions,
//                   insertions: let insertions,
//                   modifications: let modifications):
//          Log.debug("pizza collectionType: \(pizza)")
//          Log.debug("pizza deletions: \(deletions)")
//          Log.debug("pizza insertions: \(insertions)")
//          Log.debug("pizza modifications: \(modifications)")
//      case .error(let error):
//          Log.error("notification error \(error)")
//      case .initial(let results):
//          Log.debug("let initial lizer notification Token \(results)")
//      }
//  })
