//
//  TodoStore.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import SwiftUI

//                              UserRepository                                            CoreData
// TodoStore --->-protocol-<-- TodoRepository ---상속---> BaseRepository --->protocol <--- RealmStore (입출력)
// MissionStore               MissionRepository                                           FireStore
@MainActor
final class TodoStore: ObservableObject {
    
    @Published var todos: [Todo] = []
    
    var readyTodos: [Todo] {
        todos.filter { $0.status == .ready && $0.startTime.isToday }
    }
    
    var complteTodos: [Todo] {
        todos.filter { $0.status == .complete }
    }
    
    var giveUpTodos: [Todo] {
        todos.filter { $0.status == .giveUp }
    }
    
    var ongoingTodos: [Todo] {
        todos.filter { $0.status == .ongoing }
    }
    
    var doneTodos: [Todo] {
        todos.filter { $0.status == .done }
    }
    /// 완료한 todos
    @Published var complteTask: Int = 0
    
    // MARK: DI - propertywrapper OR init, dicontainer
    //    struct Dependency {
    //        var todoRepository: TodoRepository
    //    }
    //    private let repository: TodoRepositoryProtocol
    //
    //    init(repository: TodoRepositoryProtocol) {
    //        self.repository = repository
    //    }
    //    @Injected var repository: TodoRepositoryProtocol
    
    @Injected(TodoRepoKey.self) var repository: TodoRepositoryProtocol
    @Injected(UserRepoKey.self) var userRepository: UserRepositoryProtocol
    
    func getSeletedTodo(id: String) -> Todo {
        if let todo = self.todos.filter { $0.id == id }.first {
            return todo
        } else {
            assert(false, "getSeleted Todo Failed")
        }
    }
    
    @discardableResult
    func fetch() async -> [Todo] {
        await withCheckedContinuation { continuation in
            repository.fetchTodo(sorted: Sorted(key: "startTime", ascending: true)) { value in
                self.todos = value
                continuation.resume(with: .success(value))
            }
        }
    }
    
    func add(todo: Todo) -> Todo {
        do {
            let object = try repository.saveTodo(todo: todo)
            return Todo.mapFromPersistenceObject(object)
        } catch {
            Log.error("failed")
            assert(false)
        }
    }
    
    func delete(todo: Todo) {
        repository.deleteTodo(model: todo)
        self.todos.removeAll(where: { $0.id == todo.id })
    }
    
    /// 전체 목록 Delete
    /// - Parameter todo: todo Struct
    func deleteAll(todo: Todo) {
        repository.deleteAll()
    }
    
    func update(todo: Todo) -> Todo {
        let object = repository.updateTodo(todo: todo)
        return Todo.mapFromPersistenceObject(object)
    }
    
    func updateStatus(status: TodoStatus) {
        
    }
    
    /// 빈 모델 생성
    func create() {
        repository.create { value in
            Log.debug(value)
        }
    }
    
    func fixNotification(computedTodo: Todo,
                         notificationManager: NotificationManager) {
        // 할일의 시작시간 -3분에 알람을 알려줄 시간 변수
        let fixedNotificationTime = Calendar.current.dateComponents([.hour, .minute], from: computedTodo.startTime.adding(minutes: -3))
        Log.error("computedTodo.id: \(computedTodo.id)")
        // 2번 만약 처음 등록한 할일의 시작시간과 수정한 할일의 시작시간이 다를 경우, 처음 등록된 Notificatio Identifier을 찾아서 삭제하는 메서드
        notificationManager.removeSpecificNotification(id: [computedTodo.id]) // <- 처음 할일에 id를 넣어줘야, 그걸 찾아서 삭제함
        
        // 3번 수정된 할일 등록시 Notification Identifier에 computedTodo.id 넣어놓음, id 수정해야함
        
        let fixednotification = LocalNotification(identifier: computedTodo.id,
                                                  title: "현실도 피자",
                                                  body: "\(computedTodo.content) 시작 3분전이에요",
                                                  dateComponents: fixedNotificationTime,
                                                  repeats: false,
                                                  type: .calendar)
        // notification 변수를 넣어줌으로써 알림 등록, 4번은 AddTodoView에 있음( 할일을 삭제시 해당 등록된 알람도 제거)
        notificationManager.scheduleNotification(localNotification: fixednotification)
    }
    
    func notificationAdding(todo: Todo,
                            notificationManager: NotificationManager) {
        // 할일의 시작시간 -3분에 알람을 알려줄 시간 변수
        let startNotificationTime = Calendar.current.dateComponents([.hour, .minute], from: todo.startTime.adding(minutes: -3))
        Log.error("todo.id: \(todo.id)")
        // 1번 처음 할일 등록시 Notification Identifier에 todo.id 넣어놓음, id 수정해야함
        let notification = LocalNotification(identifier: todo.id,
                                             title: "현실도 피자",
                                             body: "\(todo.content) 시작 3분전이에요",
                                             dateComponents: startNotificationTime,
                                             repeats: false,
                                             type: .calendar)
        // notification 변수를 넣어줌으로써 알림 등록
        notificationManager.scheduleNotification(localNotification: notification)
    }
    
    func doneNotificationAdding(todo: Todo, notificationManager: NotificationManager) {
        let addTime: TimeInterval = todo.targetTime
        let doneNotificationTime = Calendar.current.dateComponents([.hour, .minute, .second], from: todo.startTime.addingTimeInterval(addTime))
        print("\(doneNotificationTime)")
        Log.error("todo.id: \(todo.id)")
        
        let notification = LocalNotification(identifier: todo.id,
                                             title: "현실도 피자",
                                             body: "\(todo.content) 목표시간이 완료 됐어요",
                                             dateComponents: doneNotificationTime,
                                             repeats: false,
                                             type: .calendar)
        // notification 변수를 넣어줌으로써 알림 등록
        notificationManager.scheduleNotification(localNotification: notification)
    }
    
    func deleteNotification(todo: Todo,
                            notificationManager: NotificationManager) {
        notificationManager.removeSpecificNotification(id: [todo.id])
    }
}
