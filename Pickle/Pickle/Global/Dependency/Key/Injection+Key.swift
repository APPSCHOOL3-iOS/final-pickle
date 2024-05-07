//
//  Injection+Key.swift
//  Pickle
//
//  Created by 박형환 on 10/7/23.
//

import Foundation

protocol InjectionKey {
    associatedtype Value
    static var currentValue: Self.Value { get }
    static var type: InstanceType { get }
}

extension InjectionKey {
    static var currentValue: Value {
        return Container.resolve(type, Self.self)!
    }
}

struct TodoRepoKey: InjectionKey {
    typealias Value = TodoRepositoryProtocol
    static var type: InstanceType = .singleton
}

struct DBStoreKey: InjectionKey {
    typealias Value = DBStore
    static var type: InstanceType = .singleton
}

struct TimeRepoKey: InjectionKey {
    typealias Value = TimeRepositoryProtocol
    static var type: InstanceType = .singleton
}

struct BehaviorRepoKey: InjectionKey {
    typealias Value = BehaviorRepositoryProtocol
    static var type: InstanceType = .singleton
}

struct UserRepoKey: InjectionKey {
    typealias Value = UserRepositoryProtocol
    static var type: InstanceType = .singleton
}

struct PizzaRepoKey: InjectionKey {
    typealias Value = PizzaRepositoryProtocol
    static var type: InstanceType = .singleton
}
