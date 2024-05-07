//
//  UserStore.swift
//  Pickle
//
//  Created by 박형환 on 10/10/23.
//

import SwiftUI
import Combine

final class UserStore: ObservableObject {
    
    @Injected(UserRepoKey.self) var userRepository: UserRepositoryProtocol
    
    @Published var user: User = User.defaultUser
    @Published var currentPizza: CurrentPizza = .init(pizza: nil)
    
    var token: RNotificationToken?
    
    private var subscriptions = Set<AnyCancellable>()
    
    var pizzaSlice: Double {
        return Double(user.currentPizzas.map(\.currentPizzaSlice).reduce(0, +))
    }
    
    var pizzaCount: Int {
        user.currentPizzas.map(\.currentPizzaCount).reduce(0, +)
    }
    
    enum Action {
        case unlock(Pizza)
        case select(Pizza)
        case create
        case delete
        case update(CurrentPizza)
    }
    
    func trigger(action: Action) {
        switch action {
        case .select(let pizza):
            let isNotLock = isNotLockPizza(pizzaID: pizza.id)
            if isNotLock { self.selectCurrentPizza(pizza: pizza) }
        default:
            break
        }
    }
    
    @MainActor
    func fetchUser() throws {
        do {
            self.user = try userRepository.fetchUser()
            let current = user.getCurrentPizza(using: user.pizzaID)
            if let current {
                self.currentPizza = current
            }
        } catch {
            Log.error("failed : \(error)")
            throw error
        }
    }
    
    deinit {
        self.token?.invalidate()
    }
    
    func selectCurrentPizza(pizza: Pizza) {
        user.updatePublihser(path: \.pizzaID, to: pizza.id)
            .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: false)
            .withUnretained(self)
            .map { store, model -> AnyPublisher<User, Never> in
                store.userRepository.update(seleted: model)
                    .replaceError(with: store.user)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sinkToResult(with: self) { store, result in
                switch result {
                case .success(let success):
                    store.user = success
                    store.currentPizza  = success.currentPizzas.filter { $0.pizza!.id == success.pizzaID }.first!
                    store.subscriptions.removeAll()
                case .failure(let failure):
                    Log.error("error occur : \(failure)")
                }
            }
            .store(in: &subscriptions)
    }
    
    func addUser(default user: User = User.defaultUser) {
        do {
            try userRepository.addUser(model: user)
            self.user = user
        } catch {
            Log.error("Add User 발생")
            assert(false, "Add User error발생")
        }
    }
    
    func addPizzaCount() {
        let currentPizzaCount = self.currentPizza.addPizzaCount()
        Log.debug("pizza 획득 : \(currentPizzaCount) 개")
        let user = self.user.update(current: self.currentPizza)
        self.updateUser(user: user)
    }
    
    func addPizzaSlice(slice count: Int = 1) throws {
        self.currentPizza.addPizzaSliceValidation(count: count)
        let user = self.user.update(current: self.currentPizza)
        self.updateUser(user: user)
    }
    
    func updateUser(user: User) {
        do {
            try userRepository.updateUser(model: user)
            self.user = user
        } catch {
            Log.error("update User Failed")
            assert(false, "update User Failed")
        }
    }
    
    /// 피자를 언락 하기 위한 메서드
    /// - Parameter pizza: 언락할 피자를 인자로 받는다
    func unLockPizza(pizza: Pizza) throws {
        do {
            try self.user.unlockPizza(pizza: pizza)
            try userRepository.updateUser(model: user)
        } catch {
            Log.error("\(error)")
            if let unlock = error as? User.UnlockError {
                throw unlock
            }
        }
    }
    
    func deleteuserAll() {
        do {
            try userRepository.deleteAll()
        } catch {
            Log.error("\(error)")
        }
    }
    
    private func isNotLockPizza(pizzaID: String) -> Bool {
        if let currentPizza = user.getCurrentPizza(using: pizzaID),
           let lock = currentPizza.pizza?.lock {
            return !lock
        }
        return false
    }
}
