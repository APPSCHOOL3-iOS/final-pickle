//
//  Service-PropertyWrapper.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import Foundation

@propertyWrapper
struct Injected<Dependency> {
    
    var service: Dependency
    
    // MARK: After
    init<T>(_ key: T.Type, _ type: InstanceType = .automatic) where T: InjectionKey, Dependency == T.Value {
        let service: Dependency = key.currentValue
        self.service = service
    }
    
    var wrappedValue: Dependency {
        get { self.service }
        mutating set { service = newValue }
    }
}
