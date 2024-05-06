//
//  PizzaRepository.swift
//  Pickle
//
//  Created by 박형환 on 10/17/23.
//

import Foundation

protocol PizzaRepositoryProtocol: Dependency {
    func fetch(sorted: Sorted, _ completion: @escaping ([Pizza]) -> Void)
    func create(pizza: Pizza) async throws -> Pizza
    func save(pizza: Pizza) throws
    func deleteAll() throws
    func update(pizza: Pizza) throws
}

final class PizzaRepository: BaseRepository<PizzaObject>, PizzaRepositoryProtocol {

    func fetch(sorted: Sorted, _ completion: @escaping ([Pizza]) -> Void) {
        super.fetch(PizzaObject.self,
                    predicate: nil,
                    sorted: Sorted.createdAscending, completion: { object in
            let pizzas = object.map { Pizza.mapFromPersistenceObject($0) }
            completion(pizzas)
        })
    }

    func create(pizza: Pizza) async throws -> Pizza {
        try await withCheckedThrowingContinuation { continuation in
            do {
                let data = try JSONEncoder().encode(pizza)
                try super.create(PizzaObject.self, data: data, completion: { pizzaObject in
                    let model = Pizza.mapFromPersistenceObject(pizzaObject)
                    continuation.resume(returning: model)
                })
            } catch {
                continuation.resume(throwing: PersistentedError.createFailed)
            }
        }
    }
    
    func save(pizza: Pizza) throws {
        let object = pizza.mapToPersistenceObject()
        do {
            try super.save(object: object)
        } catch {
            throw PersistentedError.saveFailed
        }
    }

    func deleteAll() throws {
        do {
            try super.deleteAll(PizzaObject.self)
        } catch {
            Log.error("\(error)")
            throw PersistentedError.deleteAllFailed
        }
    }
    
    func update(pizza: Pizza) throws {
        let object = pizza.mapToPersistenceObject()
        do {
            try super.update(object: object)
        } catch {
            Log.error("\(error)")
            throw PersistentedError.updateFaild
        }
    }
}
