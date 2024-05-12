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
        
        HStack {
            Text(task.startTime.format(timeFormat))
            Text(spendTimeFormatted)
        }
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    NewTaskRowView(task: Todo.sample)
}
