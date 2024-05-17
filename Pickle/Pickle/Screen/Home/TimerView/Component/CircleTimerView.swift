//
//  CircleTimerView.swift
//  Pickle
//
//  Created by 박형환 on 1/16/24.
//

import SwiftUI

struct CircleTimerView: View {
    
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var pizzaTaskActivity: PizzaLiveActivity
    
    var todo: Todo
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let minimumSpendTime: TimeInterval = 5 * 60 // 5분 이후
    
    @State private var progress: CGFloat = 0
    @Binding var state: TimerView.TimerState
    @Binding var isRunTimer: Bool
    @Binding var backgroundNumber: Int
    
    var targetTime: String {
        Date.convertTargetTimeToString(timeInSecond: todo.targetTime)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.clear)
                .frame(width: .screenWidth * 0.75)
                .overlay(Circle().stroke(.tertiary, lineWidth: 5))
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.pickle, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: .screenWidth * 0.75)
                .rotationEffect(.degrees(-90))
            
            CircleTimeLabel(
                timerViewModel: timerViewModel,
                isStart: state.isStart,
                targetTime: targetTime
            )
            .onReceive(timer) { _ in
                withAnimation { caclProgress() }
                handleTimerEvent()
            }
        }
    }
    
    private func handleTimerEvent() {
        if 타이머_실행전 {
            timerViewModel.timeRemaining -= 1
            return
        }
        
        if 타이머_시작 {
            let startTime = Date()
            
            pizzaTaskActivity.startTimerActivity(
                taskID: todo.id,
                content: todo.content,
                closedRange: startTime...Date(timeInterval: todo.targetTime, since: startTime)
            )
            
            calcRemain(startTime: startTime)
            return
        }
        
        if 타이머_진행중_시간_감소 {
            timerViewModel.timeRemaining -= 1
            timerViewModel.spendTime += 1
            if timerViewModel.spendTime > minimumSpendTime { state.isDisabled = false }
            if timerViewModel.timeRemaining <= 0 { turnMode() }
            return
        }
        
        if 타이머_진행중_시간_증가 {
            
            if timerViewModel.spendTime > minimumSpendTime { state.isDisabled = false }
            
            if (!state.isStart && !state.isComplete) || timerViewModel.isPuase {
                timerViewModel.timeExtra += 1
                timerViewModel.spendTime += 1
            }
            return
        }
    }
    
    private func caclProgress() {
        if state.isStart {
            progress = CGFloat(0)
        } else if timerViewModel.isDecresing {
            progress = (CGFloat(state.settingTime - timerViewModel.timeRemaining) / CGFloat(state.settingTime))
        } else {
            progress = 1
        }
    }
    
    // 남은 시간 계산하기
    // 시작 시 시간시간 업데이트, status ongoing으로
    private func calcRemain(startTime: Date) {
        state.isStart = false
        
        timerViewModel.onGoingStart(todoStore)
        state.realStartTime = startTime
        backgroundNumber = 1
        isRunTimer = true
        
        state.settingTime = todo.targetTime
        timerViewModel.timeRemaining = state.settingTime
        timerViewModel.spendTime = 0
    }
    
    /// 지정해놓은 시간 이 지났을때 decreasing mode 에서 -> increasing mode로 변경
    private func turnMode() {
        timerViewModel.isDecresing = false
        
        let newDate = Date()
        pizzaTaskActivity.updateActivity(range: newDate...Date(timeInterval: 60 * 180, since: newDate))
        
        Task {
            try await notificationManager.requestNotiAuthorization()
            notificationManager.timerViewPushSetting(LocalNotification.timer)
        }
    }
}
extension CircleTimerView {
    private var 타이머_실행전: Bool {
        state.isStart && timerViewModel.timeRemaining > 0
    }
    
    private var 타이머_시작: Bool {
        state.isStart && timerViewModel.timeRemaining <= 0
    }
    
    private var 타이머_진행중_시간_감소: Bool {
        !state.isStart && timerViewModel.isDecresing && (!state.isComplete || timerViewModel.isPuase)
    }
    
    private var 타이머_진행중_시간_증가: Bool {
        !state.isStart && !timerViewModel.isDecresing
    }
}
