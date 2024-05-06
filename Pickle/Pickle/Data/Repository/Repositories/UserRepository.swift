//
//  UserRepository.swift
//  Pickle
//
//  Created by 박형환 on 10/10/23.
//

import Foundation
import RealmSwift
import Combine
    
protocol UserRepositoryProtocol: Dependency, AnyObject {
    func getUser(_ completion: @escaping (Result<User, PersistentedError>) -> Void)
    func fetchUser() throws -> User
    func addUser(model: User) throws
    func updateUser(model: User) throws
    func deleteAll() throws
    /// User Notification Change Observe function
    /// - Parameters:
    ///   - id: specific ID
    ///   - keyPaths: observe KeyPath
    /// - Returns: NotificationToken
    func observeUser(id: String,
                     keyPaths: [PartialKeyPath<UserObject>],
                     _ completion: @escaping ObjectCompletion<UserObject>) throws -> RNotificationToken
    
    func update(seleted user: User) -> Future<User, Error>
}

final class UserRepository: BaseRepository<UserObject>, UserRepositoryProtocol {
    
    func fetchUser() throws -> User {
        do {
            let value = try super.fetch(UserObject.self,
                                        predicate: nil,
                                        sorted: nil)
            if let first = value.first {
                return User.mapFromPersistenceObject(first)
            } else {
                throw PersistentedError.fetchUserError
            }
        } catch {
            throw PersistentedError.fetchUserError
        }
    }
   
    func getUser(_ completion: @escaping (Result<User, PersistentedError>) -> Void) {
        super.fetch(UserObject.self,
                    predicate: nil,
                    sorted: Sorted.createdAscending,
                    completion: { user in
            if let userObject = user.first {
                let user = User.mapFromPersistenceObject(userObject)
                completion(.success(user))
            } else {
                completion(.failure(.fetchError))
            }
        })
    }
    
    func addUser(model: User) throws {
        let object = model.mapToPersistenceObject()
        do {
            try super.save(object: object)
        } catch {
            throw PersistentedError.addFaild
        }
    }
    
    func updateUser(model: User) throws {
        let object = model.mapToPersistenceObject()
        do {
            try super.update(object: object)
        } catch {
            throw PersistentedError.addFaild
        }
    }
    
    func update(seleted user: User) -> Future<User, Error> {
        Future<User, Error> { promise in
            do {
                guard
                    let store = super.dbStore as? RealmStore
                else {
                    return promise(.failure(PersistentedError.updateFaild))
                }
                let object = user.mapToPersistenceObject()
                
                try store.update(object: object)
                
                return promise(.success(user))
            } catch {
                return promise(.failure(PersistentedError.updateFaild))
            }
        }
    }
    
    func deleteAll() throws {
        do {
            try super.deleteAll(UserObject.self)
        } catch {
            throw PersistentedError.deleteFailed
        }
    }
    
    func observeUser(id: String, 
                     keyPaths: [PartialKeyPath<UserObject>],
                     _ completion: @escaping ObjectCompletion<UserObject>) throws -> RNotificationToken {
        do {
            return try self.dbStore.notificationToken(UserObject.self,
                                                      id: id,
                                                      keyPaths: keyPaths,
                                                      completion)
        } catch {
            Log.error("error occur notification token")
            assert(false, "failed get observed User Token ")
            throw error
        }
    }
}
