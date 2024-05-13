//
//  ReadyTaskView.swift
//  Pickle
//
//  Created by kaikim on 5/13/24.
//

import SwiftUI

struct ReadyTaskView: View {
    let task: Todo
    var body: some View {
        VStack {
            Section("실패이다") {
                Text(task.content)
            }
        }
    }

}

