//
//  PickleTestApp.swift
//  PickleTests
//
//  Created by 박형환 on 11/4/23.
//

import SwiftUI

class TestAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}

struct PickleAppTest: App {
    var body: some Scene {
        WindowGroup {
            VStack {
                Text("TEST")
            }
        }
    }
}
