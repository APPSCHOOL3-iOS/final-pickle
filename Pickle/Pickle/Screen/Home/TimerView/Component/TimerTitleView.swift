//
//  TimerTitle.swift
//  Pickle
//
//  Created by 박형환 on 1/16/24.
//

import SwiftUI
import PickleCommon

struct TimerTitleView: View, Equatable {
    
    @Binding var isStart: Bool
    var todo: Todo
    
    var body: some View {
        VStack {
            /// 멘트부분
            if isStart {
                Text("따라 읽어봐요!")
                    .font(.pizzaRegularTitle)
            
            } else {
                VStack(spacing: 30) {
                    Text(todo.content)
                        .font(.pizzaRegularTitle)
                        .frame(width: .screenWidth - 50)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.horizontal, 10)
                    
                    Text("🍕가 구워지고 있어요")
                        .font(.pizzaBoldButtonTitle15)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, .screenHeight * 0.05)
    }
    
    static func == (lhs: TimerTitleView, rhs: TimerTitleView) -> Bool {
        lhs.isStart == rhs.isStart && lhs.todo.content == rhs.todo.content
    }
}
