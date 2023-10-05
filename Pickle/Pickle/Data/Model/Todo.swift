//
//  Todo.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/26.
//

import Foundation

struct Todo: Identifiable {
    let id: String
    var content: String
    var startTime: Date     // 시작 시간 (15시부터)
    var targetTime: Int    // 목표 시간 (16시까지)
    var spendTime: Date     // 실제 종료 시간 (16시반까지)
    var status: Status
}

typealias TodoStatus = Status
enum Status: String {
    // 진행전 진행중 완료 포기
    case ready
    case ongoing
    case done
    case giveUp
    
    var value: String {
        self.rawValue
    }
}

extension Todo: MappableProtocol {
    
    typealias PersistenceType = TodoObject
    
    func mapToPersistenceObject() -> TodoObject {
        return TodoObject(content: self.content,
                          startTime: self.startTime,
                          targetTime: Date(), //self.targetTime,
                          spendTime: self.spendTime,
                          status: TodoStatusPersisted(rawValue: self.status.value) ?? .ready)
    }
    
    static func mapFromPersistenceObject(_ object: TodoObject) -> Todo {
        let todo: Todo = Todo(id: object.id.stringValue,
                              content: object.content,
                              startTime: object.startTime,
                              targetTime: 0,
                              spendTime: object.spendTime,
                              status: TodoStatus(rawValue: object.status.rawValue) ?? .ready)
        return todo
    }
}

let sampleTodoList: [Todo] = [
    Todo(id: UUID().uuidString,
         content: "이력서 작성하기",
         startTime: Date(),
         targetTime: 3600,
         spendTime: Date() + 5400,
         status: .ready),
    Todo(id: UUID().uuidString,
         content: "ADS 작성하기",
         startTime: Date(),
         targetTime: 1800,
         spendTime: Date() + 1800,
         status: .ready),
    Todo(id: UUID().uuidString,
         content: "Readme 작성하기",
         startTime: Date(),
         targetTime: 5400,
         spendTime: Date() + 3600,
         status: .ready),
]
