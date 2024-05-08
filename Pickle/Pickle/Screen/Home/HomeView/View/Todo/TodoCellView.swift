//
//  TodoCellView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct TodoCellView: View {
    
    @AppStorage(STORAGE.is24HourClock.id) var is24HourClock: Bool = true
    @AppStorage(STORAGE.timeFormat.id) var timeFormat: String = "HH:mm"
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationStore: NavigationStore
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var notificationManager: NotificationManager
    
    var todo: Todo
    
    struct Selection {
        var selectedTodo: Todo = Todo.sample
        var isShowingTimer: Bool = false
    }
        
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(todo.content)
                        .font(.pizzaBody)
                    
                    Text("\(todo.startTime.format(timeFormat)) (\(convertSecondsToTime(timeInSecond: Int(todo.targetTime))))")
                        .font(.nanumBdBody)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    navigationStore.pushHomeView(home: .isShowingTimerView(todo))
                    todoStore.deleteNotificaton(todo: todo, noti: notificationManager)
                    
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.clear)

                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.pickle)
                    }
                }
            }
            .padding(.horizontal)
            .frame(height: 80)
            .background(Color.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12)) // clip corners
            .background(
                RoundedRectangle(cornerRadius: 12) // stroke border
                    .stroke(Color.defaultGray, lineWidth: 1.5)
            )
        }
        .onAppear {
            timeFormat = is24HourClock ? "HH:mm" : "a h:mm"
        }
    }
    
    func convertSecondsToTime(timeInSecond: Int) -> String {
        let minutes = timeInSecond / 60 // 분
        return String(format: "%02i분", minutes)
        
    }
}

struct TodoCellView_Previews: PreviewProvider {
    static var previews: some View {

        TodoCellView(todo: Todo(id: UUID().uuidString,
                                content: "이력서 작성하기",
                                startTime: Date(),
                                targetTime: 3600,
                                spendTime: 5400,
                                status: .ready))
    }
}
