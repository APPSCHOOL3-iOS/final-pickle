//
//  HomeViewModel.swift
//  Pickle
//
//  Created by 박형환 on 11/17/23.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    typealias PizzaSelection = PizzaSelectedView.Selection
    typealias PositionID = PizzaPagingView.ScrollPizzaID
    
    /*피자 가로 스크롤 뷰 x offset*/
    @Published var offset: CGFloat = 0
    
    /*피자 한 페이지당 width geo.size.width - pagePadding*/
    @Published var pizzaScrollViewWidth: CGFloat = 0
    
    @Published var pizzaSelection: PizzaSelection = .init()
    
    @Published var pizzaPosition: PositionID = .pizza("")
    
    @Published var currentPositionPizza: CurrentPizza = .init(pizza: .defaultPizza)
    
    @Published var description: String = "피자를 완성하면 얻을수 있어요"
    
    enum Action {
        case unlock(UserStore, Pizza)
        case updatePosition(User)
        case updateCurrent(CurrentPizza)
    }
    
    enum Effect {
        case unlockFail(Int)
        case success
        case unknown
    }
    
    @discardableResult
    func trigger(action: HomeViewModel.Action) -> Effect? {
        switch action {
        case .unlock(let userStore, let pizza):
            return self.unLockPizzaAction(userStore: userStore, pizza: pizza)
            
        case .updatePosition(let user):
            self.updatePositionPizza(user: user)
            return nil
        case .updateCurrent(let currentPizza):
            if let pizza = currentPizza.pizza {
                pizzaPosition = .pizza(pizza.id)
                currentPositionPizza = currentPizza
            }
            return nil
        }
    }
    
    private func unLockPizzaAction(userStore: UserStore, pizza: Pizza) -> Effect {
        do {
            try userStore.unLockPizza(pizza: pizza) /*pizzaSelection.seletedPizza*/
            return .success
        } catch {
            if let unlock = error as? User.UnlockError {
                if case let .notMeet(count) = unlock {
                    Log.debug("이만큼 부족함 : \(count)")
                    return .unlockFail(count)
                }
            }
            return .unknown
        }
    }
    
    func gesturePositionUpdate(user: User) {
        let positionIndex: Int = Int(abs(offset) / pizzaScrollViewWidth)
        guard let positionID = user.currentPizzas[safe: positionIndex]?.pizza?.id else { return }
        
        pizzaPosition = .pizza(positionID)
        updatePositionPizza(user: user, positionID: positionID)
    }
    
    private func updatePositionPizza(user: User, positionID: String = "") {
        var positionID = positionID
        
        if positionID.isEmpty {
            if case let .pizza(ID) = self.pizzaPosition {
                positionID = ID
            }
        }
        
        let pizza = user.getCurrentPizza(using: positionID)
        if let pizza {
            currentPositionPizza = pizza
        }
    }
    
    private func pizzasIDs(user: User) -> [String] {
        user.currentPizzas.compactMap(\.pizza).map(\.id)
    }
    
    private func currentPizzaPosition(user: User) -> Int {
        if case let .pizza(ID) = pizzaPosition {
            guard let index = pizzasIDs(user: user).firstIndex(of: ID) else { return 0 }
            return index
        }
        return 0
    }
    
    func remainder(offset: CGFloat) -> CGFloat {
        abs(offset).remainder(dividingBy: pizzaScrollViewWidth)
    }
    
    func nextPizzaScrollPosition(user: User, direction: Bool = true) {
        let index = currentPizzaPosition(user: user)
        let count = user.currentPizzas.count
        
        let defaultPosition: Int
        let nextPosition: Int
        let condition: Bool
        defaultPosition = direction ? 0 : count - 1
        nextPosition = direction ? index + 1 : index - 1
        condition = direction ? index == count - 1 : index == 0
        
        let positionID = condition
        ?
        user.currentPizzas[safe: defaultPosition]?.pizza?.id ?? ""
        :
        user.currentPizzas[safe: nextPosition]?.pizza?.id ?? ""
        
        pizzaPosition = .pizza(positionID)
    }
    
}
