//
//  R.swift
//  PickleCommon
//
//  Created by 박형환 on 5/11/24.
//

import SwiftUI

public enum FontError: Error {
    case invalidFontFile
    case fontPathNotFound
    case initFontError
    case registerFailed
}

private class R { }

public extension Font {
    
    static func register(fileNameString: String, type: String) throws {
        let bundle = Bundle(for: R.self)
        
        guard let url = bundle.url(forResource: fileNameString, withExtension: type) else {
            throw FontError.fontPathNotFound
        }
        
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
