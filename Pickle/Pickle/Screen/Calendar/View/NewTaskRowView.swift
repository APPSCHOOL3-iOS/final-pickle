//
//  NewTaskRowView.swift
//  Pickle
//
//  Created by kaikim on 5/12/24.
//

import SwiftUI

struct NewTaskRowView: View {
    
    @AppStorage(STORAGE.timeFormat.id) private var timeFormat: String = "H:m"
    
    var task : Todo
    var spendTimeFormatted: String {
        String(format: "%d분", Int(task.spendTime)/60)
    }

    var body: some View {
        
        VStack {
            switch task.status {
            case .done:
                SuccessTaskView(task: task)
            default: ReadyTaskView(task: task)
            }
        }
        
    }
    

}

#Preview {
    NewTaskRowView(task: Todo.sample)
}
