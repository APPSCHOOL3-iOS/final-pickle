//
//  LiveActivityCountDownView.swift
//  Pickle
//
//  Created by 박형환 on 5/12/24.
//

import SwiftUI
import PickleCommon

@available(iOS 17.0, *)
public struct LiveActivityCountDownView: View {
    var state: TaskLiveActivityAttributes.ContentState
    var content: String
    
    public var body: some View {
        VStack(alignment: .center) {
            Text(content)
                .font(.pizzaTimerNum)
                .padding(.leading, 15)
                .padding(.trailing, 20)
                .padding(.vertical, 10)
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .background(
                    ZStack(alignment: .trailing) {
                        Capsule()
                            .fill(Color.pickle.opacity(0.6))
                    }
                )
                .padding(.top, 15)
                .padding(.horizontal, 10)
            
            HStack {
                Spacer(minLength: 15)
                ModeTimerText(
                    state: state,
                    font: .pizzaTimerNum
                )
                .padding(.leading, 10)
                .padding(.bottom, 10)
            }
        }
    }
}

@available(iOS 17.0, *)
struct ModeTimerText: View {
    let state: TaskLiveActivityAttributes.ContentState
    let font: Font
    
    var body: some View {
        if state.taskMode == .decreasing {
            Text.init(
                timerInterval: state.taskTime
            )
            .foregroundColor(.pickle)
            .font(font)
            .padding(.horizontal, 10)
            
        } else if state.taskMode == .increasing {
            HStack {
                Text("+")
                    .foregroundColor(.pickle)
                    .font(font)
                    .padding(.horizontal, 10)
                
                Text.init(
                    timerInterval: state.taskTime,
                    countsDown: false
                )
                .foregroundColor(.pickle)
                .font(font)
            }
        } 
    }
}

@available(iOS 17.0, *)
struct TimerProgressView: View {
    
    let workoutDateRange: ClosedRange<Date>
    
    var body: some View {
        ProgressView(
            timerInterval: workoutDateRange,
            countsDown: false,
            label: { EmptyView() },
            currentValueLabel: { EmptyView() }
        )
        .tint(.pickle)
        .progressViewStyle(.circular)
    }
}
