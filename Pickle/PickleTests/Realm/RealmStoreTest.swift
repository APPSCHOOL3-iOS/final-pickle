//
//  RealmStoreTest.swift
//  PickleTests
//
//  Created by 박형환 on 11/5/23.
//

import XCTest
@testable import Pickle
import Combine


final class RealmStoreTest: XCTestCase {
    
    var sut: RealmStore!
    
    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = RealmStore(type: .inmemory)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func test_create_todo() throws {
        // Given
        let object = TodoObject.todo
        let expectation = XCTestExpectation(description: "todo Create")
        let completion: (Storable) -> Void = { value in
            let casting = value as? TodoObject
            XCTAssertNotNil(casting)
            let flag = self.equalTodoObject(object: object, casting: casting!)
            XCTAssertTrue(flag)
            XCTAssertNotEqual(object, casting!) // 객체의 내용은 같으나 다른곳에서 생성된 객체이기에 not equal
            expectation.fulfill()
        }
        // When
        try sut.create(TodoObject.self, item: object, completion: completion)
        
        // Then
        wait(for: [expectation])
    }
    
    func test_update() throws {
        // Given
        for _ in 0..<3 {
            let todo = Todo.mapFromPersistenceObject(TodoObject.todo)
            let readyTodo = todo.update(path: \.status, to: TodoStatus.ready)
            let object = readyTodo.mapToPersistenceObject()
            try sut.create(TodoObject.self, item: object, completion: { _ in })
            
            // When
            let addedObject = Todo.mapFromPersistenceObject(object)
            
            let future = addedObject.update(path: \.status, to: TodoStatus.ongoing)
            
            let futureObject = future.mapToPersistenceObject()
            
            let filterd: RealmFilter<TodoObject> = { query in
                query.status.equals(.ready)
            }
            
            let updatedValue = try sut.update(TodoObject.self,
                                              item: futureObject,
                                              query: filterd)
            
            // Then
            XCTAssertEqual(updatedValue.status, .ongoing)
        }
    }
    
    func test_fetch() throws {
        // Given
        let todos = sampleTodoList
        let todoObject = todos.map { $0.mapToPersistenceObject() }
        let readyFilter: RealmFilter<TodoObject> = { query in
            query.status.equals(.ready)
        }
        let ongoinFilter: RealmFilter<TodoObject> = { query in
            query.status.equals(.ongoing)
        }
        let completeFilter: RealmFilter<TodoObject> = { query in
            query.status.equals(.complete)
        }
        
        // When
        try sut.deleteAll(TodoObject.self)
        _ = try todoObject.compactMap {
            try sut.create(TodoObject.self, item: $0, completion: { _ in })
        }
        
        let readys = try sut.fetch(TodoObject.self, filtered: readyFilter, sorted: nil)
        let ongoings = try sut.fetch(TodoObject.self, filtered: ongoinFilter, sorted: nil)
        let completes = try sut.fetch(TodoObject.self, filtered: completeFilter, sorted: nil)
        
        // Then
        XCTAssertEqual(readys.count, 1)
        XCTAssertEqual(ongoings.count, 1)
        XCTAssertEqual(completes.count, 1)
    }
    
    /// 특정 한개의 객체 업데이트 테스트
    func test_specific_Object_Update() throws {
//        // Given
//        let userObject = User.defaultUser.mapToPersistenceObject()
//        
//        try sut.create(UserObject.self, item: userObject, completion: { value in
//            XCTAssertEqual(value.nickName, userObject.nickName)
//        })
//        let fetchedUser = try sut.fetch(UserObject.self,
//                                        filtered: { value in value.nickName.equals(userObject.nickName)},
//                                        sorted: nil)
//        
//        XCTAssertNotEqual(fetchedUser.first!, userObject)  // user는 UUID fetch는 ObjectID
//        XCTAssertEqual(fetchedUser.first!.createdAt, userObject.createdAt)
//        
//        let unwrap = fetchedUser.first!
//        let pizzas: [PizzaObject] = unwrap.pizza.map { $0 }
//        
//        _ = pizzas.filter { $0.image == "potato" }.first!
//        // potatoPizza.lock = false write Transaction 밖에서 수정은 할 수 없다
//        
//        let fetchedPotato = try sut.fetch(PizzaObject.self,
//                                          filtered: { pizza in pizza.image.equals("potato")},
//                                          sorted: nil)
//        
//        XCTAssertEqual(fetchedPotato.first!.image, "potato")
//        XCTAssertEqual(fetchedPotato.first!.lock, true)
//        
        //        let newPotato = try sut.update(PizzaObject.self,
        //                                            id: unwrap.id.stringValue,
        //                                            item: potatoPizza) { query in query.image.equals("potato") }
        // primary key가 없는 오브젝트는 create .update 옵션으로 명시적으 업데이트 할 수 없다.
        // MARK: UserStoreTest 81번 테스트 코드 확인 -> 유저 오브젝트의 primary키로 전체를 덮어 씌우도록 업데이트
    }
}

extension RealmStoreTest {
    func equalTodoObject(object: TodoObject, casting: TodoObject) -> Bool {
        if object.id == casting.id &&
            object.content == casting.content &&
            object.startTime == casting.startTime &&
            object.spendTime == casting.spendTime &&
            object.targetTime == casting.targetTime &&
            object.status == casting.status {
            return true
        } else {
            return false
        }
    }
}
