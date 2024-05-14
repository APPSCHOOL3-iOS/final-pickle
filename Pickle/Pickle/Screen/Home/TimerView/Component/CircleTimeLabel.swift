//
//  CircleTimeLabel.swift
//  Pickle
//
//  Created by 박형환 on 5/10/24.
//

import SwiftUI
import PickleCommon

struct CircleTimeLabel: View {
    
    @ObservedObject var timerViewModel: TimerViewModel
    var isStart: Bool
    var targetTime: String
    
    init(timerViewModel: TimerViewModel, isStart: Bool, targetTime: String) {
        self.timerViewModel = timerViewModel
        self.isStart = isStart
        self.targetTime = targetTime
    }
    
    var body: some View {
        Group {
            if isStart {
                if timerViewModel.timeRemaining > 0 {
                    Text(String(format: "%g", timerViewModel.timeRemaining))
                        .foregroundColor(.pickle)
                        .font(.pizzaTimerNum)
                } else {
                    Text("시작")
                        .foregroundColor(.pickle)
                        .font(.pizzaTimerNum)
                }
            } else {
                if timerViewModel.isDecresing {
                    // 남은시간 줄어드는 타이머
                    decreasingView
                } else {
                    // 추가시간 늘어나는 타이머
                    increasingView
                }
                
                // 목표시간 명시
                Text(targetTime)
                    .font(.pizzaRegularSmallTitle)
                    .foregroundColor(.secondary)
                    .offset(y: 40)
            }
        }
    }
    
    private var decreasingView: some View {
        Text(Date.convertSecondsToTime(timeInSecond: timerViewModel.timeRemaining))
            .foregroundColor(.pickle)
            .font(.pizzaTimerNum)
    }
    
    // 추가시간 늘어나는 타이머
    private var increasingView: some View {
        HStack {
            Text("+ \(Date.convertSecondsToTime(timeInSecond: timerViewModel.timeExtra))")
                .foregroundColor(.pickle)
                .font(.pizzaTimerNum)
        }
    }
}
