//
//  URL.swift
//  Pickle
//
//  Created by 박형환 on 10/5/23.
//

import Foundation

// MARK: - appending file Path
extension URL {
    static func inDocumentsFolder(_ name: String) -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let _path = path.appendingPathComponent(name)
        return _path
    }
}
