//
//  TestStore.swift
//  PickleTests
//
//  Created by 박형환 on 11/4/23.
//

import XCTest
@testable import Pickle

struct TestStoreKey: InjectionKey {
    typealias Value = TestStore
    static var type: InstanceType = .automatic
}

struct TestStore: DBStore {
    func update<T>(_ model: T.Type, item: T, query: Pickle.RealmFilter<T>?) throws -> T where T: Pickle.Storable {
        fatalError()
    }
    
    func update<T>(_ model: T.Type, id: String, item: T, query: Pickle.RealmFilter<T>?) throws -> T where T: RObject, T: Pickle.Storable {
        fatalError()
    }
    
    func create<T>(_ model: T.Type, item: T, completion: @escaping (T) -> Void) throws where T: Pickle.Storable {
        fatalError()
    }
    
    func create<T>(_ model: T.Type, data: Data, completion: @escaping (T) -> Void) throws where T: Pickle.Storable {
        fatalError()
    }
    
    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Pickle.Sorted?) throws -> [T] where T: Pickle.Storable {
        fatalError()
    }
    
    func notificationToken<T>(_ model: T.Type, 
                              id: String,
                              keyPaths: [PartialKeyPath<T>],
                              _ completion: @escaping Pickle.ObjectCompletion<T>) throws -> Pickle.RNotificationToken where T: Pickle.Storable {
        fatalError()
    }
    
    func create<T>(_ model: T.Type, completion: @escaping (T) -> Void) throws where T: Pickle.Storable {
        fatalError()
    }
    
    func save(object: Pickle.Storable) throws {
        return
    }
    
    func update(object: Pickle.Storable) throws {
        fatalError()
    }
    
    func delete(object: Pickle.Storable) throws {
        fatalError()
    }
    
    func delete<T>(model: T.Type, id: String) throws where T: Pickle.Storable {
        fatalError()
    }
    
    func deleteAll<T>(_ model: T.Type) throws where T: Pickle.Storable {
        fatalError()
    }
    
    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Pickle.Sorted?, complection: ([T]) -> Void) throws where T: Pickle.Storable {
        fatalError()
    }
}
