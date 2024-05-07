//
//  User-extension.swift
//  Pickle
//
//  Created by 박형환 on 10/18/23.
//

import Foundation

extension User: MappableProtocol {
    typealias PersistenceType = UserObject
    
    func mapToPersistenceObject() -> PersistenceType {
        let list = self.currentPizzas.map { $0.mapToPersistenceObject() }
        return UserObject(id: self.id,
                          nickName: self.nickName,
                          currentPizzaCount: self.currentPizzaCount,
                          currentPizzaSlice: self.currentPizzaSlice,
                          currentPizzaID: self.pizzaID,
                          currentPizzaList: list,
                          createdAt: self.createdAt)
    }
    
    static func mapFromPersistenceObject(_ object: PersistenceType) -> Self {
        return User(id: object.id,
                    nickName: object.nickName,
                    currentPizzaCount: object.currentPizzaCount,
                    currentPizzaSlice: object.currentPizzaSlice,
                    pizzaID: object.currentPizzaID,
                    currentPizzas: object.currentPizzaList.map { CurrentPizza.mapFromPersistenceObject($0) },
                    createdAt: object.createdAt)
    }
}
