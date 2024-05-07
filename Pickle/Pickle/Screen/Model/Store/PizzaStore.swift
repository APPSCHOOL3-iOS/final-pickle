//
//  PizzaStore.swift
//  Pickle
//
//  Created by 박형환 on 10/17/23.
//

import Foundation

@MainActor
class PizzaStore: ObservableObject {
    
    @Injected(PizzaRepoKey.self) var pizzaRepository: PizzaRepositoryProtocol
    
    func fetch() async -> [Pizza] {
        await withCheckedContinuation { continuation in
            pizzaRepository.fetch(sorted: Sorted.createdAscending) { pizza in
                continuation.resume(returning: pizza)
            }
        }
    }
    
    func add(pizza: Pizza) throws {
        do {
            try pizzaRepository.save(pizza: pizza)
        } catch {
            throw error
        }
    }
    
    func create(pizza: Pizza) async throws -> Pizza {
        do {
            let value = try await pizzaRepository.create(pizza: pizza)
            return value
        } catch {
            Log.error("\(error)")
            throw error
        }
    }
    
    func update(pizza: Pizza) {
        do {
            try pizzaRepository.update(pizza: pizza)
        } catch {
            Log.error("value failed : \(error)")
        }
    }
    
    func deleteAll() {
        do {
            try pizzaRepository.deleteAll()
        } catch {
            Log.error("delete All Failed \(error)")
        }
    }
}
