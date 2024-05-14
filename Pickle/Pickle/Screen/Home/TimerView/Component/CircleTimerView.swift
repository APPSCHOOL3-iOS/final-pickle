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
    
    // 남은시간 줄어드는 타이머
    private var decreasingView: some View {
        Text(Date.convertSecondsToTime(timeInSecond: timerVM.timeRemaining))
            .foregroundColor(.pickle)
            .font(.pizzaTimerNum)
            .onReceive(timer) { _ in
                if !state.isComplete || timerVM.isPuase {
                    timerVM.timeRemaining -= 1
              
                    timerVM.spendTime += 1
                    
                    if timerVM.spendTime > completeLimit { state.isDisabled = false }
                    if timerVM.timeRemaining <= 0 { turnMode() }
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
    }
    
    // 추가시간 늘어나는 타이머
    private var increasingView: some View {
        HStack {
            Text("+ \(Date.convertSecondsToTime(timeInSecond: timerVM.timeExtra))")
                .foregroundColor(.pickle)
                .font(.pizzaTimerNum)
                .onReceive(timer) { _ in
                    // disabled가 풀리기 전에 background 갔다가 오는 경우를 위해
                    if timerVM.spendTime > completeLimit {
                        state.isDisabled = false
                    }
                    if (!state.isStart && !state.isComplete) || timerVM.isPuase {
                        timerVM.timeExtra += 1
                        timerVM.spendTime += 1
                    }
                }
        }
    }
    
    private func progress() -> CGFloat {
        if state.isStart {
            return CGFloat(0)
        } else {
            if timerVM.isDecresing {
                return (CGFloat(state.settingTime - timerVM.timeRemaining) / CGFloat(state.settingTime))
            } else {
                return 1
            }
        }
    }
    
    // 남은 시간 계산하기
    // 시작 시 시간시간 업데이트, status ongoing으로
    private func calcRemain() {
        state.isStart = false
        
        timerVM.onGoingStart(todoStore)
        state.realStartTime = Date()
        backgroundNumber = 1
        isRunTimer = true
        
        state.settingTime = todo.targetTime
        timerVM.timeRemaining = state.settingTime
        timerVM.spendTime = 0
    }
    
    /// 지정해놓은 시간 이 지났을때 decreasing mode 에서 -> increasing mode로 변경
    private func turnMode() {
        timerVM.isDecresing = false
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
