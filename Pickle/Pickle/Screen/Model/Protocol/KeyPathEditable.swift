//
//  KeypathI.swift
//  Pickle
//
//  Created by 박형환 on 10/18/23.
//

import Foundation
import Combine

enum KeyPathError: Error {
    case unableToCast(String)
}

protocol KeyPathEditable {
    func update<KeyPathType>(path: PartialKeyPath<Self>, to value: KeyPathType) throws -> Self
}

extension KeyPathEditable {
    func update<KeyPathType>(path: PartialKeyPath<Self>, to value: KeyPathType) -> Self {
        guard let writableKeyPath = path as? WritableKeyPath<Self, KeyPathType> else {
            // throw KeyPathError.unableToCast("이 \(value) 데이터는 값타입이 아니에유;;")
            return self
        }
        var copy = self
        copy[keyPath: writableKeyPath] = value
        return copy
    }
    
    func updatePublihser<KeyPathType>(path: PartialKeyPath<Self>,
                                      to value: KeyPathType) -> AnyPublisher<Self, KeyPathError> {
        Future<Self, KeyPathError> { promise in
            guard let writableKeyPath = path as? WritableKeyPath<Self, KeyPathType> else {
                return promise(.failure(KeyPathError.unableToCast("이 \(value) 데이터는 값타입이 아니에유;;")))
            }
            var copy = self
            copy[keyPath: writableKeyPath] = value
            promise(.success(copy))
        }
        .eraseToAnyPublisher()
    }
}

extension Todo: KeyPathEditable {}
extension BehaviorMission: KeyPathEditable {}
extension TimeMission: KeyPathEditable {}
extension User: KeyPathEditable {}
extension Pizza: KeyPathEditable {}
