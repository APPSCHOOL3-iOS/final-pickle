//
//  TodoStoreTest.swift
//  PickleTests
//
//  Created by 박형환 on 11/4/23.
//

import XCTest
import Combine
@testable import Pickle

final class TodoStoreTest: XCTestCase {
    
    var sut: TodoStore!
    
    var subscriptions = Set<AnyCancellable>()
    
    @MainActor override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Self.setUpTodoDependency()
        sut = TodoStore()
        print("setup")
        
    }

    @MainActor
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut.deleteAll(todo: .sample)
        Container.removeCache()
        subscriptions.removeAll()
        sut = nil
    }
    
    /// 정확한 객체들이 프로토콜타입으로 추가되었는지 확인
    @MainActor
    func test_check_correct_Instance() async {
        let todoReposiotry = sut.repository
        let userRepo = sut.userRepository
        XCTAssertNotNil(todoReposiotry as? TodoRepository, "todo protocol is todoRepository")
        XCTAssertNotNil(userRepo as? UserRepository, "user protocol is UserRepository")
        XCTAssertNotNil(todoReposiotry as? BaseRepository<TodoObject>, "TodoRepo baseRepository")
        XCTAssertNotNil(userRepo as? BaseRepository<UserObject>, "UserRepo baseRepository")
    }
    
    /// 한개의 TODO를 추가한 케이스
    @MainActor
    func test_addSuccessValue_TodoStore() async throws {
        // Given
        let todo = Todo.sample
        
        // When
        let addedTodo = sut.add(todo: todo)
        let fetchedTodos = await sut.fetch()
        let fetchedApplyNewIdInMemeoryTodo = fetchedTodos.map { todo.changeID(id: $0.id) }
        
        // Then
        XCTAssertEqual(fetchedTodos, fetchedApplyNewIdInMemeoryTodo)
        XCTAssertEqual([addedTodo], fetchedTodos)
        XCTAssertEqual([addedTodo], fetchedApplyNewIdInMemeoryTodo)
    }
    
    /// 여러개의 Todo를 DB에 추가하는 케이스
    @MainActor
    func test_multiple_adding_test() async throws {
        // Given
        let todos = (0...10).map { _ in Todo.mock }
        
        // When
        for todo in todos {
            _ = sut.add(todo: todo)
        }
        let fetched = await sut.fetch()
        
        // Then
         XCTAssertEqual(fetched, todos, "todos가 일치하지 않습니다.")
    }
    
    @MainActor
    func test_AddFaildValue_TodoStore() async throws {
        // Given
        let todo = Todo.sample
        
        // When
        let addedMemoryTodo = sut.add(todo: todo)
        let fetchedTodo = await sut.fetch()
        let publishedTodo = sut.todos
        let sampleTodo = todo.changeID(id: fetchedTodo.first!.id)
        
        // Then
        XCTAssertEqual([addedMemoryTodo], fetchedTodo)
        XCTAssertEqual([addedMemoryTodo], publishedTodo)
        XCTAssertEqual(fetchedTodo, publishedTodo)
        XCTAssertEqual([sampleTodo], fetchedTodo)
        // XCTAssertNotEqual([todo], fetchedTodo)
    }
    
    /// Todo 아이템 10개를 추가후
    /// 개별 삭제 메서드로 한개씩 전체 삭제
    @MainActor
    func test_adding_delete_oneByone() async throws {
        // Given
        _ = (0...10).map { _ in Todo.sample }
        // var results: [Todo] = []
        // var changedIdTodos: [Todo] = []
        // await adding_todos(todos: originalTodo, results: &results, &changedIdTodos)
        
        // When
        let deletedTodos = await sut.fetch()
        deletedTodos.forEach { sut.delete(todo: $0) }
        let fetchedTodos = await sut.fetch()
        let memoryTodos = sut.todos
        
        // Then
        XCTAssertEqual(fetchedTodos, memoryTodos)
        XCTAssertEqual([], fetchedTodos)
        XCTAssertEqual([], memoryTodos)
    }
    
    /// Todo 아이템 10개를 추가후
    /// deleteAll 메서드 전체삭제
    @MainActor
    func test_add_delete() async throws {
        
        // Given
        let originalTodo = sampleTodoList
        
        let expectation = XCTestExpectation()
        try await Task.sleep(seconds: 1)
        expectation.fulfill()
        await fulfillment(of: [expectation])
        for todo in originalTodo {
            _ = sut.add(todo: todo)
        }
        
        // When
        let deletedTodos = await sut.fetch()
        sut.deleteAll(todo: .sample)
        let fetchedTodos = await sut.fetch()
        let memoryTodos = sut.todos
        
        // Then
        XCTAssertNotEqual(deletedTodos, fetchedTodos)
        XCTAssertNotEqual(deletedTodos, memoryTodos)
        XCTAssertEqual(fetchedTodos, memoryTodos)
        XCTAssertEqual([], fetchedTodos)
        XCTAssertEqual([], memoryTodos)
    }
    
    /// Todo를 1개 추가
    /// Update  -> fetch 하는 테스트
    @MainActor
    func test_update() async throws {
        // Given
        let todo = Todo.sample
        
        // When
        let value = sut.add(todo: todo)
        let updatedTodo = value.update(path: \.status, to: TodoStatus.ongoing)
        let memoryUpdatedTodo = sut.update(todo: updatedTodo)
        
        let fetchedTodo = await sut.fetch().first!
        
        // Then
        XCTAssertEqual(updatedTodo.status, .ongoing)
        XCTAssertEqual(updatedTodo, memoryUpdatedTodo)
        XCTAssertEqual(updatedTodo, fetchedTodo)
        XCTAssertEqual(fetchedTodo, memoryUpdatedTodo)
    }
    
    /// 선택한  투두  값을 가져오는지 테스트
    @MainActor
    func test_getSeleted_todo() async throws {
        // Given
        let ready = sut.add(todo: Todo.mock)
        let ongoing = Todo.mock.update(path: \.status, to: TodoStatus.ongoing)
        let complete = Todo.mock.update(path: \.status, to: TodoStatus.complete)
        let done = Todo.mock.update(path: \.status, to: TodoStatus.done)
        let fail = Todo.mock.update(path: \.status, to: TodoStatus.fail)
        _ = sut.add(todo: ongoing)
        _ = sut.add(todo: complete)
        _ = sut.add(todo: done)
        _ = sut.add(todo: fail)
        
        // When
        _ = await sut.fetch()
        let readyTodo = sut.readyTodos.first!
        let seletedTodo = sut.getSeletedTodo(id: readyTodo.id)
        
        // Then
        XCTAssertEqual(sut.readyTodos.count, 1)
        XCTAssertEqual(ready, seletedTodo)
        XCTAssertTrue(seletedTodo.isEqualContent(todo: ready))
    }
    
    @MainActor
    func test_Future_fetch() throws {
        // Given
        for i in 0...2 {
            _ = sut.add(todo: sampleTodoList[i])
        }
        
        let expectation = XCTestExpectation(description: "futureTest")
        sut.repository.fetcthFuture(model: TodoObject.self)
            // .receive(on: DispatchQueue.main) 다른 스레드에서 realm 객체 접근 불가
            .sink(
                receiveCompletion: { com in
                    Log.debug(com)
                    expectation.fulfill()
                },
                receiveValue: { value in
                    Log.debug(value)
                    XCTAssertEqual(value.count, 3)
                }
            ).store(in: &subscriptions)
        
        // When
        // Then
        wait(for: [expectation])
    }
}

extension Todo {
    func changeID(id: String) -> Todo {
        Todo(id: id,
             content: self.content,
             startTime: self.startTime,
             targetTime: self.targetTime,
             spendTime: self.spendTime,
             status: self.status)
    }
}

extension TodoStoreTest {
    static func setUpTodoDependency() {
        Container.register(DBStoreKey.self, RealmStore(type: .inmemory))
        Container.register(TodoRepoKey.self, TodoRepository())
        Container.register(UserRepoKey.self, UserRepository())
    }
}
