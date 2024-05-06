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
    @EnvironmentObject var timerVM: TimerViewModel
    
    var todo: Todo
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let completeLimit: TimeInterval = 5 * 60 // 5분 이후
    @Binding var state: TimerView.TimerState
    @Binding var isRunTimer: Bool
    @Binding var backgroundNumber: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.clear)
                .frame(width: .screenWidth * 0.75)
                .overlay(Circle().stroke(.tertiary, lineWidth: 5))
            Circle()
                .trim(from: 0, to: progress())
                .stroke(Color.pickle, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: .screenWidth * 0.75)
                .rotationEffect(.degrees(-90))
            
            if state.isStart {
                if timerVM.timeRemaining > 0 {
                    Text(String(format: "%g", timerVM.timeRemaining))
                        .foregroundColor(.pickle)
                        .font(.pizzaTimerNum)
                        .onReceive(timer) { _ in
                            timerVM.timeRemaining -= 1
                        }
                } else {
                    Text("시작")
                        .foregroundColor(.pickle)
                        .font(.pizzaTimerNum)
                        .onReceive(timer) { _ in
                            calcRemain()
                        }
                }
            } else {
                if timerVM.isDecresing {
                    // 남은시간 줄어드는 타이머
                    decreasingView
                } else {
                    // 추가시간 늘어나는 타이머
                    increasingView
                }
                
                // 목표시간 명시
                Text(Date.convertTargetTimeToString(timeInSecond: todo.targetTime))
                    .font(.pizzaRegularSmallTitle)
                    .foregroundColor(.secondary)
                    .offset(y: 40)
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
