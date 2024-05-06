//
//  RealmStore+Combine.swift
//  PickleTests
//
//  Created by 박형환 on 11/6/23.
//

import XCTest
import Combine
@testable import Pickle

final class RealmStoreCombineTest: XCTestCase {
    
    var sut: RealmStore!
    var subscriptions = Set<AnyCancellable>()
    
    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = RealmStore(type: .inmemory)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        subscriptions = []
    }
    
    func test_fetch_using_publisher() throws {
        // Given
        let expectation = XCTestExpectation(description: "combine Test")
        
        for i in 0...2 {
            let object = sampleTodoList[i].mapToPersistenceObject()
            try sut.create(TodoObject.self, item: object, completion: {_ in })
        }
        let query: RealmFilter<TodoObject> = { value in
            value.status.contains(.ongoing)
        }
        // When
        // Then
        let publisher = sut.fetchPublisher(TodoObject.self, query: query)
        
            publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { value in
                XCTAssertEqual(value.count, 1) // 이 컨텍스트에서 ongoing은 한개
            }).store(in: &subscriptions)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            expectation.fulfill()
        })
        wait(for: [expectation])
    }
}
