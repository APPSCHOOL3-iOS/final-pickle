//
//  UserStoreTest.swift
//  PickleTests
//
//  Created by 박형환 on 11/4/23.
//

import XCTest
@testable import Pickle

final class UserStoreTest: XCTestCase {
    
    var sut: UserStore!
    
    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Self.setUpTodoDependency()
        sut = UserStore()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut.deleteuserAll()
        sut = nil
    }
    
    /// 유저 add후 fetch UUID가 아닌 ObjectID 불일치
    /// id만 ObjectID 변경후 일치하는지 테스트
    /// -> (변경) -> ObjectID 삭제 완료 UUID가 일치하는지 테스트 변경
    /// 1. 유저를 추가
    /// 2. UUID 일치 하는 지 확인
    @MainActor
    func test_생성한유저와_페치이후_유저가_일치하는지_테스트() async throws {
        // Given
        let user = User.defaultUser
        
        // When
        sut.addUser(default: user)
        try sut.fetchUser()
        
        // Then
        // -> CurrentPizza의 ID는 매번 UUID로 생성 되므로 다른 값이 온다
        XCTAssertNotEqual(user.currentPizzas, sut.user.currentPizzas)
        
        XCTAssertEqual(user.id, sut.user.id)
        XCTAssertEqual(user.pizzaID, sut.user.pizzaID)
        XCTAssertEqual(user.currentPizzas.compactMap(\.pizza),
                       sut.user.currentPizzas.compactMap(\.pizza))
    }
    
    /// 유저 Pizza 전체 잠금 update 테스트
    /// 1. 유저 추가
    /// 2. 모든 currentPizza를 업데이트 시도합니다.
    /// 3. 조건에 달성하지 못했으므로 lock 변수는 false를 반환합니다.
    /// 페퍼로니는 기본 피자 로 false 값이 기본값
    /// 테스트후 (변경점) -> unlockPizza Method에 이미 lock false인 값은 elary return 으로 잠금 중복 업데이트 방지 코드 추가
    @MainActor
    func test_피자_잠금_업데이트_실패_테스트() async throws {
        // Given
        let user = User.defaultUser
        sut.addUser(default: user)
        try sut.fetchUser()
        var fetchedUser = sut.user
        
        try fetchedUser.currentPizzas.forEach { currentPizza in
            if let pizza = currentPizza.pizza {
                do {
                    try fetchedUser.unlockPizza(pizza: pizza)
                } catch {
                    guard
                        let error = error as? User.UnlockError
                    else {
                        XCTFail("예상한 오류 타입이 아닙니다.")
                        throw error
                    }
                    let lock = User.PizzaUnlockCondition.init(rawValue: "\(pizza.image)")
                    XCTAssertNotNil(lock)
                    XCTAssertEqual(error, .notMeet(lock!.condition))
                }
            }
        }
        fetchedUser.currentPizzas.forEach { currentPizza in
            XCTAssertNotNil(currentPizza.pizza)
            if currentPizza.pizza!.image == "pepperoni" {
                XCTAssertFalse(currentPizza.pizza!.lock)
                return
            }
            XCTAssertTrue(currentPizza.pizza!.lock)
        }
    }
    
    /// 특정 피자만 unlock 하는 update 테스트
    /// 1. 유저 추가
    /// 2. unlockPizza 메소드 호출
    /// 3. fetch 호출
    /// 4. 결과 확인
    /// 현재 lock 조건이 있으므로 error 방충 올바른 error가 오는지 test
    @MainActor
    func test_update_specific_pizza() async throws {
        // Given
        try await addingAndFetchUser()
        let potato
        =
        sut.user.getCurrentPizza(match: .potato)!.pizza!
        
        let expectation = XCTestExpectation.init(description: "UnlockError")
        
        // When
        do {
            try sut.unLockPizza(pizza: potato)
        } catch {
            let error = error as? User.UnlockError
            XCTAssertNotNil(error)
            if case let .notMeet(value) = error {
                
                XCTAssertEqual(value, User.PizzaUnlockCondition.potato.condition)
                // 언락 실패시 에러 UnlockError 방출
                // 현재 추가한 피자 조각이 없으므로 potato.condition 만큼 에러 방출
                Log.debug("value1")
                expectation.fulfill()
            }
        }
        
        try sut.fetchUser()
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        let fetechdPotato =
        sut.user.currentPizzas
            .compactMap(\.pizza)
            .filter { $0.image == "potato" }.first!
        
        // Then
        XCTAssertEqual(potato.lock, true)
        XCTAssertEqual(fetechdPotato.lock, true) // 조건을 충족하지 못해서 업데이트 실패
    }
    
    /// 피자 잠금해제 조건은 User.PizzalockCondition enum에 condition 연산 프로퍼티로 조건을 지정해 놓았습니다.
    /// User.PizzaUnlockCondition
    /// 2개의 pizzaCount를 추가합니다.
    @MainActor
    func test_치즈피자_조건충족했을때_잠금해제할수있는지() async throws {
        // Given
        try await addingAndFetchUser()
        
        // When
        try await 피자_카운트늘리는_함수()
        try await 피자_카운트늘리는_함수()
        
        let cheesPizza = sut.user.getCurrentPizza(match: .cheese)!.pizza!
        XCTAssertEqual(cheesPizza.lock, true)
        do {
            try sut.unLockPizza(pizza: cheesPizza)
        } catch {
            XCTFail("조건을 충족 했으므로 에러가 나오면 안됨")
        }
        
        // Then
        let cheese = sut.user.getCurrentPizza(match: .cheese)!.pizza!
        XCTAssertEqual(cheese.lock, false)
    }
    
    /// User가 가지고 있는 pizzaSlice 업데이트 테스트
    /// 1. 유저 추가
    /// 2. 피자 조각 업데이트
    /// 3. 현재 피자조각 8개 이상일시 피자 한판 추가 후 피자 조각 0으로 초기화 테스트
    /// 4. 결과 확인
    /// 변경 -> 유저가 가진 피자 조각, 갯수에서 -> 피자 마다 조각 개수를 가지도록 변경
    /// 현재 homeView에서 currentPizza가 변할때 마다 조각수가 8개 이상일때 명시적으로 addPizzaCount를 호출하고 있음
    /// 8개 이상일때 addPizzaCount를 호출해야됩니다.
    func test_update_pizza_slice() async throws {
        // Given
        try await addingAndFetchUser()
        
        // When
        // 피자 조각 1개 추가
        // 현재 지정된 피자의 조각 추가
        try self.sut.addPizzaSlice(slice: 4)
        
        await waitTask(for: 0.3)
        XCTAssertEqual(self.sut.currentPizza.currentPizzaSlice, 4)
        
        try self.sut.addPizzaSlice(slice: 4)
        self.sut.addPizzaCount()
        await waitTask(for: 0.3)
        
        // Then
        XCTAssertEqual(self.sut.currentPizza.currentPizzaCount, 1)
        XCTAssertEqual(self.sut.currentPizza.currentPizzaSlice, 0)
    }
    
    func test_잠금되어있는_피자_선택_불가능한지_테스트() async throws {
        // Given
        try await addingAndFetchUser()
        
        let seletedPizza = sut.user.getCurrentPizza(match: .potato)!.pizza!
        let beforeSeletedPizza = sut.currentPizza
        
        // When
        // sut.selectCurrentPizza(pizza: seletedPizza)
        sut.trigger(action: .select(seletedPizza))
        await waitTask(for: 0.4)
        
        // Then
        XCTAssertEqual(beforeSeletedPizza, sut.currentPizza)
    }
    
    func test_잠금해제후_피자_선택_가능한지_테스트() async throws {
        // Given
        try await addingAndFetchUser()
        
        // When
        let seletedPizza = sut.user.getCurrentPizza(match: .potato)!.pizza!
        _ = sut.currentPizza
        
        for _ in 0..<4 {
            try await 피자_카운트늘리는_함수() // 포테이토 피자 잠금조건 4개 이상 획득 충족
        }
        
        await waitTask(for: 0.2)
        try sut.unLockPizza(pizza: seletedPizza)
        sut.trigger(action: .select(seletedPizza))
        
        await waitTask(for: 0.5)
        
        // Then
        XCTAssertEqual(seletedPizza.id, sut.currentPizza.pizza!.id)
        XCTAssertEqual(seletedPizza.name, "포테이토 피자")
        XCTAssertNotEqual(seletedPizza.lock, sut.currentPizza.pizza!.lock)
    }
    
    /// 특정 피자만 unlock 하는 update 테스트
    /// 1. 유저 추가
    /// 2. unlockPizza 메소드 호출
    /// 3. fetch 호출이 아닌 observe 하고 있는 notifiction으로 업데이트
    /// 4. 결과 확인
    func test_update_observeTest() async throws {
        // Given
        try await addingAndFetchUser()
         // let potato = sut.user.pizzas.filter { $0.image == "potato" }.first!
         // XCTAssertEqual(potato.lock, true)
        
        // When
        // sut.unLockPizza(pizza: potato)
        // await waitTask(for: 1)
        
        // Then
        // let potatoPizzas = sut.user.pizzas.filter { $0.image == "potato" }.first!
        // XCTAssertEqual(potatoPizzas.lock, false)
    }
    
    /// Default User 추가후 fetch해오는 함수
    @MainActor
    private func addingAndFetchUser() async throws {
        let user = User.defaultUser
        sut.addUser(default: user)
        try sut.fetchUser()
    }
    
    private func 피자_카운트늘리는_함수(slice: Int = 8) async throws {
        try self.sut.addPizzaSlice(slice: slice)
        self.sut.addPizzaCount()
    }
}

extension UserStoreTest {
    static func setUpTodoDependency() {
        Container.register(DBStoreKey.self, RealmStore(type: .inmemory))
        Container.register(UserRepoKey.self, UserRepository())
    }
}
