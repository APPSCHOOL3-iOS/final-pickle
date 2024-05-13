//
//  SuccessTaskView.swift
//  Pickle
//
//  Created by kaikim on 5/13/24.
//

import SwiftUI

struct SuccessTaskView: View {
    let task: Todo
    var body: some View {
        VStack {
            Section("성공이다") {
                Text(task.content)
            }
            
        }
    }
}
