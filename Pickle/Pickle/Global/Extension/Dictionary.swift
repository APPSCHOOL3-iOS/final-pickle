//
//  Dictionary.swift
//  Pickle
//
//  Created by 박형환 on 11/10/23.
//

import Foundation

extension Dictionary where Key == AnyHashable, Value: Any {
    func mapToStringKey() -> [String: Any] {
        self.reduce(into: [String: Any]()) { original, dic in
            guard let key = dic.key as? String else { return }
            original[key] = dic.value
        }
    }
}
