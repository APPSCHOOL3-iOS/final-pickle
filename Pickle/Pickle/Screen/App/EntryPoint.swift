//
//  EntryPoint.swift
//  Pickle
//
//  Created by 박형환 on 11/4/23.
//

import SwiftUI

@main
struct AppLauncher {
    @MainActor
    static func main() {
        if NSClassFromString("XCTestCase") != nil {
            PickleAppTest.main()
        } else {
            PickleApp.main()
        }
    }
}
