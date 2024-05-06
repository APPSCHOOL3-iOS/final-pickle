//
//  CurrentPizza.swift
//  Pickle
//
//  Created by 박형환 on 11/13/23.
//

import Foundation

struct CurrentPizza: Identifiable {
    let id: String
    var currentPizzaCount: Int
    var currentPizzaSlice: Int
    var pizza: Pizza?
    var createdAt: Date  // 유저 계정 생성 날짜,시간
    
    init(id: String = UUID().uuidString,
         currentPizzaCount: Int = .init(),
         currentPizzaSlice: Int = .init(),
         pizza: Pizza?,
         createdAt: Date = .init()) {
        self.id = id
        self.currentPizzaCount = currentPizzaCount
        self.currentPizzaSlice = currentPizzaSlice
        self.pizza = pizza
        self.createdAt = createdAt
    }
    
    var goalTotal: Double {
        8 // 피자 완성 카운트
    }
    var taskPercentage: Double {
        Double(self.currentPizzaSlice) / goalTotal
    }
    var pizzaTaskSlice: String {
        /// Pizza  ex) 1 / 8 - 유저의 완료한 피자조각 갯수....
        "\(Int(self.currentPizzaSlice % 8)) / \(Int(goalTotal))"
    }
    var content: String {
        self.currentPizzaSlice > 0 ? "" : "?"
    }
}

extension CurrentPizza: Equatable {
    static func == (lhs: CurrentPizza, rhs: CurrentPizza) -> Bool {
        lhs.id == rhs.id &&
        lhs.pizza == rhs.pizza &&
        lhs.currentPizzaSlice == rhs.currentPizzaSlice &&
        lhs.currentPizzaCount == rhs.currentPizzaCount &&
        lhs.createdAt == rhs.createdAt
    }
    
    /// 피자 조각을 추가하고 , 8조각 이상일시 슬라이스를 0으로 만들고 피자카운트를 (1 = defaut) 증가 시키는 메서드
    /// - Parameter count: 피자 조각갯수
    mutating func addPizzaSliceValidation(count: Int = 1) {
        currentPizzaSlice += count
    }
    
    mutating func addPizzaCount() -> Int {
        var count: Int = 0
        while currentPizzaSlice >= 8 {
            currentPizzaSlice -= 8
            currentPizzaCount += 1
            count += 1
        }
        return count
    }
}
