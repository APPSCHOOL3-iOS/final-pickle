//
//  Todo.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/26.
//

import Foundation
import RealmSwift

enum TodoError: Error {
    case id
}

struct Todo: Identifiable {
    let id: String
    var content: String
    var startTime: Date     // 시작 시간 (15시부터)
    var targetTime: TimeInterval    // 목표 소요 시간 ex) 30분
    var spendTime: TimeInterval     // 실제 소요 시간 ex) 32분
    var status: TodoStatus
    
    init(id: String, content: String, startTime: Date, targetTime: TimeInterval, spendTime: TimeInterval, status: TodoStatus) {
        self.id = id
        self.content = content
        self.startTime = startTime
        self.targetTime = targetTime
        self.spendTime = spendTime
        self.status = status
    }
    
    init(todo: Todo) {
        self.init(id: todo.id, 
                  content: todo.content,
                  startTime: todo.startTime,
                  targetTime: todo.targetTime,
                  spendTime: todo.spendTime,
                  status: todo.status)
    }
    
    init(dic: [String: Any]) {
        self.id = dic["id"] as? String ?? ""
        self.content = dic["content"] as? String ?? ""
        self.startTime = dic["startTime"] as? Date ?? Date()
        self.targetTime = dic["targetTime"] as? TimeInterval ?? 0.0
        self.spendTime = dic["spendTime"] as? TimeInterval ?? 0.0
        let string = dic["status"] as? String ?? "ready"
        self.status = .init(rawValue: string) ?? .ready
    }
}

extension Todo: Hashable {
    func isEqualContent(todo: Self) -> Bool {
        self.content == todo.content &&
        self.startTime == todo.startTime &&
        self.targetTime == todo.targetTime
    }
    
    var isNotPersisted: Bool {
        self.id == "" ||
        self.id == Todo.sample.id
    }
    
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        
        let value = mirror.children.lazy.map { (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }
        
        let dict = Dictionary(uniqueKeysWithValues: value.compactMap { $0 })
        return dict
    }
}

extension Todo: Codable { }

extension Todo {
    static var sample: Todo {
        .init(id: "SamPleTodoTestView",
              content: "Sample",
              startTime: Date(),
              targetTime: 0,
              spendTime: 10,
              status: .ready)
    }
    
    static var onGoing: Todo {
        Todo(id: "",
             content: "",
             startTime: Date(),
             targetTime: 0,
             spendTime: 0,
             status: .ongoing)
    }
}

let sampleTodoList: [Todo] = [
    Todo(id: UUID().uuidString,
         content: "이력서 작성하기",
         startTime: Date(),
         targetTime: 3600,
         spendTime: 5400,
         status: .ready),
    Todo(id: UUID().uuidString,
         content: "ADS 작성하기",
         startTime: Date(),
         targetTime: 1800,
         spendTime: 1800,
         status: .ongoing),
    Todo(id: UUID().uuidString,
         content: "Readme 작성하기",
         startTime: Date(),
         targetTime: 5400,
         spendTime: 3600,
         status: .complete),
]
