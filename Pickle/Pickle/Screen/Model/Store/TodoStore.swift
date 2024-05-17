//
//  TodoStore.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import SwiftUI
import Combine

@MainActor
final class TodoStore: ObservableObject {
    
    @Published var todos: [Todo] = []
    
    var readyTodos: [Todo] {
        todos.filter { $0.status == .ready && $0.startTime.isToday }
    }

    /// 완료한 todos
    @Published var complteTask: Int = 0
    
    @Injected(TodoRepoKey.self) var repository: TodoRepositoryProtocol
    @Injected(UserRepoKey.self) var userRepository: UserRepositoryProtocol
    
    func getSeletedTodo(id: String) -> Todo {
        if let todo = self.todos.filter({ $0.id == id }).last {
            return todo
        } else {
            // TODO: ISRuntimer check 해야함
            // assert(false, "getSeleted Todo Failed")
            // Log.error("getSeleted Todo Failed")
        }
        return Todo.sample
    }
    
    @discardableResult
    func fetch() async -> [Todo] {
        return await withCheckedContinuation { continuation in
            repository.fetchTodo(sorted: Sorted(key: "startTime", ascending: true)) { value in
                self.todos = value
                continuation.resume(with: .success(value))
            }
        }
    }
    
    func add(todo: Todo) -> Todo {
        let object = repository.saveTodo(todo: todo)
        return Todo.mapFromPersistenceObject(object)
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
    
    @discardableResult
    func update(todo: Todo) -> Todo {
        do {
            let object = try repository.updateTodo(todo: todo)
            return Todo.mapFromPersistenceObject(object)
        } catch {
            return .sample
        }
    }
    
    func fixNotification(todo: Todo, noti: NotificationManager) {
        noti.removeSpecificNotification(id: [todo.id])
        notificationAdding(todo: todo, noti: noti)
    }
    
    func notificationAdding(todo: Todo, noti: NotificationManager) {
        let notification = LocalNotification.makeLocalNotification(todo, notification: .todo(todo))
        noti.scheduleNotification(localNotification: notification)
    }
    
    func deleteNotificaton(todo: Todo, noti: NotificationManager) {
        noti.removeSpecificNotification(id: [todo.id])
    }
}
