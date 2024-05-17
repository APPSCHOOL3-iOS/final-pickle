//
//  TimerButton.swift
//  Pickle
//
//  Created by 박형환 on 1/16/24.
//

import SwiftUI
import PickleCommon

typealias DoneType = TimerCompleteButton.DoneType

struct TimerCompleteButton: View, Equatable {
    
    enum DoneType {
        case complete
        case giveUp
    }
    
    @Binding var state: TimerView.TimerState
    var action: (DoneType) -> Void
    
    var body: some View {
        return HStack {
            // 완료 버튼
            Button {
                action(.complete)
            } label: {
                Text("완료")
                    .font(.pizzaHeadline)
                    .frame(width: 75, height: 75)
                     .foregroundColor(state.isDisabled ? .secondary : .green)
                    .background(state.isDisabled ? Color(.secondarySystemBackground) : Color(hex: 0xDAFFD9))
                    .clipShape(Circle())
            }
            .disabled(state.isDisabled)
            .opacity(state.isStart ? 0.5 : 1)
            .padding([.leading, .trailing], 75)
            
            // 포기버튼
            Button(action: {
                action(.giveUp)
            }, label: {
                Text("포기")
                    .font(.pizzaHeadline)
                    .frame(width: 75, height: 75)
                     .foregroundColor(state.isStart ? .secondary : .red)
                    .background(state.isStart ? Color(.secondarySystemBackground) :Color(hex: 0xFFDBDB))
                    .clipShape(Circle())
            })
            .disabled(state.isStart)
            .opacity(state.isStart ? 0.5 : 1)
            .padding([.leading, .trailing], 75)
        }
        .padding(.top, 10)
    }
    
    static func == (lhs: TimerCompleteButton, rhs: TimerCompleteButton) -> Bool {
        lhs.state.isStart == rhs.state.isStart && 
        lhs.state.isDisabled == rhs.state.isDisabled
    }
}
