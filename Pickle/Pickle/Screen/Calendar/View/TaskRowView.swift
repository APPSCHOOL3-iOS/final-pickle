//
//  TaskRowView.swift
//  Pickle
//
//  Created by kaikim on 2023/09/27.
//

import SwiftUI

struct TaskRowView: View {
    
    @State private var isShowingReportSheet: Bool = false
    @AppStorage(STORAGE.is24HourClock.id) private var is24HourClock: Bool = true
    @AppStorage(STORAGE.timeFormat.id) private var timeFormat: String = "HH:mm"
    
    var task: Todo
    var indicatorColor: Color {
        switch task.status {
        case .done:
            return .pickle
        case .giveUp:
            return .gray
        default:
            return .pickle
        }
    }
    
    var taskSymbol: Image {
        switch task.status {
        case .done:
            return Image(systemName: "checkmark.circle.fill")
        case .giveUp:
            return Image(systemName: "xmark.circle.fill")
        default:
            return Image(systemName: "circle.dotted")
        }
    }
    
    var body: some View {
        
        if task.status == .done || task.status == .giveUp {
            
            Button {
                isShowingReportSheet = true
            } label: {
                taskRowView
            }
            .foregroundColor(.primary)
            
        } else { taskRowView }
    }
    
    @ViewBuilder
    private var taskContent: some View {
        VStack(alignment: .leading) {
            Text(task.content)
                .font( .callout)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
        }
        Spacer()
    }
    
    @ViewBuilder
    private var taskRowView: some View {
        HStack {
            taskSymbol
                .foregroundStyle(indicatorColor)
            
            taskContent
            HStack {
                if task.status == .ready && task.startTime.isSameHour {
                    Image(systemName: "clock.badge")
                        .foregroundColor(.pickle)
                        .font(.caption)
                        
                }
                Text(task.startTime.format(timeFormat))
                    .font(.footnote)
                    .fontWeight(.light)
                    
            }
            .padding(.horizontal)
        }
        .font(.callout)
        .onAppear {
            timeFormat = is24HourClock ? "HH:mm" : "a h:mm"
        }
        .hSpacing(.leading)
        .padding(.bottom, 10)
        .padding(.leading, 18)
        .padding(.trailing, 5)
        
        .sheet(isPresented: $isShowingReportSheet) {
            TimerReportView(isShowingReportSheet: $isShowingReportSheet,
                            isShowingTimerView: .constant(false),
                            todo: task)
        }
        
    }
    
}

#Preview {
    TaskRowView(task: Todo.sample)
}
