//
//  Todo-extension.swift
//  Pickle
//
//  Created by 박형환 on 10/18/23.
//

import Foundation

extension Todo: MappableProtocol {
    
    typealias PersistenceType = TodoObject
    
    func mapToPersistenceObject() -> TodoObject {
        TodoObject(id: self.id,
                   content: self.content,
                   startTime: self.startTime,
                   targetTime: self.targetTime,
                   spendTime: self.spendTime,
                   status: TodoStatusPersisted(rawValue: self.status.value) ?? .ready)
        
    }
    
    static func mapFromPersistenceObject(_ object: TodoObject) -> Todo {
        let todo: Todo = Todo(id: object.id,
                              content: object.content,
                              startTime: object.startTime,
                              targetTime: object.targetTime,
                              spendTime: object.spendTime,
                              status: TodoStatus(rawValue: object.status.rawValue) ?? .ready)
        return todo
    }
}
