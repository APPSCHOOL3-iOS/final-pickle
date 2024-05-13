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
    var spendTimeFormatted: String {
        String(format: "%d분", Int(task.spendTime)/60)
    }
    var indicatorColor: Color {
        switch task.status {
        case .done:
            return .pickle
        case .ready:
            return .gray
        default:
            return .pickle
        }
    }
    
    var taskSymbol: Image {
        switch task.status {
        case .done:
            return Image(systemName: "checkmark.circle.fill")
        case .ready:
            return Image(systemName: "clock.badge")
        case .fail :
            return Image(systemName: "circle.dotted")
        default:
            return Image(systemName: "circle.dotted")
        }
    }
    
    var body: some View {
        
        
        VStack {
            Text("ㅎㅎㅎㅎ")
//            if task.status == .done || task.status == .giveUp {
//    
//                Button {
//                    isShowingReportSheet = true
//                } label: {
//                    taskRowView
//                }
//                .foregroundColor(.primary)
//    
//            } else {
//                taskRowView          
//            }
         
        }
        
            
//            if task.status == .done {
//                Section("성공1") {
//                    Text(task.content)
//                }
//                
//            }
//            if task.status == .ready {
//                Section("성공2") {
//                    Text(task.content)
//                }
//                .formStyle(.grouped)
//            }
//            if task.status == .fail{
//                Section("성공3") {
//                    Text(task.content)
//                }
//                .formStyle(.grouped)
//                
//            }


        
        
      
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
            
            
            if task.status == .ready && task.startTime.isSameHour {
                taskSymbol.foregroundStyle(Color.pickle)
                
            }  else if task.status == .done {
                taskSymbol.foregroundStyle(Color.pickle)
            }
            taskContent
            HStack(spacing:3) {
                
                Text(task.startTime.format(timeFormat))
                if task.status != .ready && task.spendTime > 60  {
                    
                    Text("(\(spendTimeFormatted))")
                    
                        .font(.footnote)
                        .fontWeight(.light)
                }
                
            }
            //            .frame(alignment: <#T##Alignment#>)
            
            
            
            
        }
        //        .border(.pink)
        .monospacedDigit()
        .padding(.horizontal)
        .font(.callout)
        .onAppear {
            timeFormat = is24HourClock ? "HH:mm" : "a h:mm"
        }
        .hSpacing(.leading)
        .padding(.bottom, 10)
        .padding(.leading, 5)
        //        .padding(.trailing, 10)
        
        .sheet(isPresented: $isShowingReportSheet) {
            NewTaskRowView(task: task)
            //            TimerReportView(isShowingReportSheet: $isShowingReportSheet,
            //                            isShowingTimerView: .constant(false),
            //                            todo: task)
        }
        
    }
    
    
}

#Preview {
    TaskRowView(task: Todo.sample)
}
