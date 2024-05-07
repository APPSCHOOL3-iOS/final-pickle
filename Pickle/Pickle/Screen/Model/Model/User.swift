//
//  User.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/26.
//

import Foundation

struct User: Identifiable {
    let id: String
    var nickName: String
    var currentPizzaCount: Int
    var currentPizzaSlice: Int
    var pizzaID: String
    var currentPizzas: [CurrentPizza]
    var createdAt: Date  // 유저 계정 생성 날짜,시간
    
    init(id: String,
         nickName: String,
         currentPizzaCount: Int,
         currentPizzaSlice: Int,
         pizzaID: String = "",
         currentPizzas: [CurrentPizza],
         createdAt: Date) {
        self.id = id
        self.nickName = nickName
        self.currentPizzaCount = currentPizzaCount
        self.currentPizzaSlice = currentPizzaSlice
        self.pizzaID = pizzaID
        self.currentPizzas = currentPizzas
        self.createdAt = createdAt
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.nickName == rhs.nickName &&
        lhs.currentPizzaSlice == rhs.currentPizzaSlice &&
        lhs.currentPizzaCount == rhs.currentPizzaCount &&
        lhs.currentPizzas == rhs.currentPizzas &&
        lhs.pizzaID == rhs.pizzaID &&
        lhs.createdAt == rhs.createdAt
    }
    
    mutating func update(current pizza: CurrentPizza) -> Self {
        let list = self.currentPizzas.map { return $0.id == pizza.id ? pizza : $0 }
        return try! self.update(path: \.currentPizzas, to: list)
    }
    
    /// 피자 조각을 추가하고 , 8조각 이상일시 슬라이스를 0으로 만들고 피자카운트를 (1 = defaut) 증가 시키는 메서드
    /// - Parameter count: 피자 조각갯수
    mutating func addPizzaSliceValidation(count: Int = 1) -> Self {
        currentPizzaSlice += count
        if currentPizzaSlice >= 8 {
            currentPizzaSlice = 0
            currentPizzaCount += 1
        }
        return self
    }
    
    /// 피자 한개의 잠금해제 메소드
    /// - Parameter pizza: 잠금 해제할 피자
    mutating func unlockPizza(pizza: Pizza) throws {
        if !pizza.lock { return }
        let willUnlockPizza = getCurrentPizza(using: pizza.id)
    
        guard var willUnlockPizza else { return }
        
        try lockDetermine(pizza: pizza)
        
        var pizza = pizza
        pizza.lockToggle()
        willUnlockPizza.pizza = pizza
        
        self.currentPizzas = self.currentPizzas.map {
            return willUnlockPizza.id == $0.id ? willUnlockPizza : $0
        }
    }
    
    private func lockDetermine(pizza: Pizza) throws {
        guard
            let lockPizza = PizzaUnlockCondition.init(rawValue: pizza.image)
        else {
            throw UnlockError.nameMismatch
        }
        
        let currentPizzaCount = self.currentPizzas.map(\.currentPizzaCount).reduce(0, +)
        
        let condition = lockConditiion(pizza: lockPizza, pizza: currentPizzaCount)
        
        // 잠금조건이 달성 되지 않으면 해제 불가능 throw error
        if let count = condition {
            throw UnlockError.notMeet(count)
        }
    }
    
    // pizzaID 를 통해서 User의 현재 currentPizza 반환
    func getCurrentPizza(using pizzaID: String) -> CurrentPizza? {
        return self.currentPizzas.filter {
            if $0.pizza?.id == pizzaID {
                return true
            }
            return false
        }.first
    }
    
    func getCurrentPizza(match name: PizzaUnlockCondition) -> CurrentPizza? {
        currentPizzas
            .filter { $0.pizza!.image == name.rawValue }.first
    }

    // MARK: 안쓰는 메서드 확인후 삭제바람
    func update(_ status: Status) -> Self {
        User(id: self.id,
             nickName: self.nickName,
             currentPizzaCount: self.currentPizzaSlice,
             currentPizzaSlice: self.currentPizzaSlice,
             currentPizzas: self.currentPizzas,
             createdAt: self.createdAt)
    }
}

// MARK: - 피자 잠금 해제
extension User {
    
    /* 기본 페퍼로니 -> 치즈 2 (16)
     -> 포테이토 4 (32) -> 베이컨 포테이토 6 (64)
     -> 고구마 12 (128) -> 하와이안 24 (256)
     -> 마르게리타 32 (512) */
    // 카운트? , 슬라이스 로?
    
    enum UnlockError: Error, Equatable {
        // assosicatedType Int -> 부족한 조각 갯수
        case notMeet(Int)
        case nameMismatch
    }
    
    enum PizzaUnlockCondition: String {
        case pepperoni
        case cheese
        case potato
        case baconPotato
        case hawaiian
        case sweetPotato
        case margherita
        
        var condition: Int {
            switch self {
            case .pepperoni:
                return 0
            case .cheese:
                return 2
            case .potato:
                return 4
            case .baconPotato:
                return 6
            case .hawaiian:
                return 12
            case .sweetPotato:
                return 24
            case .margherita:
                return 32
            }
        }
        
        var description: String {
            "피자 \(self.condition)판을 모아야 잠금을 해제할 수 있어요"
        }
    }
    
    /// 잠금해제 조건 판별 메서드
    /// - Parameters:
    ///   - pizza: 해제할 Lock condition Case
    ///   - currentCount: 현재 가지고 있는 피자 갯수
    /// - Returns: Int -> 부족한 피자 갯수 , 성공시 nil
    private func lockConditiion(pizza: PizzaUnlockCondition, pizza currentCount: Int) -> Int? {
        let condition = pizza.condition
        switch pizza {
        default:
            return currentCount >= condition ? nil : condition - currentCount
        }
    }
}

extension User {
    static var defaultUser: User {
        let currentPizzas = Pizza.allCasePizza.map { CurrentPizza(pizza: $0) }
        return .init(id: UUID().uuidString,
                     nickName: "Guest",
                     currentPizzaCount: 0,
                     currentPizzaSlice: 0,
                     pizzaID: currentPizzas.first!.pizza!.id,
                     currentPizzas: currentPizzas,
                     createdAt: Date())
    }
}
