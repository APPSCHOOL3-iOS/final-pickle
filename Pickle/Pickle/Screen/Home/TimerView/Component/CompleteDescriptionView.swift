//
//  CompleteDescriptionView.swift
//  Pickle
//
//  Created by 박형환 on 5/10/24.
//

import SwiftUI

struct BottomDescriptionView: View {
    
    var isStart: Bool
    var isDisabled: Bool
    var wiseSaying: String
    
    var body: some View {
        if isDisabled && !isStart {
            CompleteDescriptionView()
        } else if !isDisabled && !isStart {
            WiseSayingView(text: wiseSaying)
        }
    }
}

struct WiseSayingView: View {
    var text: String
    
    var body: some View {
        Text("\(text)")
            .multilineTextAlignment(.center)
            .lineSpacing(10)
            .font(.pizzaBoldButtonTitle15)
             .foregroundColor(.secondary)
            .frame(width: .screenWidth - 50)
            .lineLimit(4)
            .minimumScaleFactor(0.7)
            .padding(.top, 50)
            .padding(.bottom, .screenHeight * 0.1)
            .padding(.horizontal, 20)
    }
}

struct CompleteDescriptionView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("최소 5분 할 일을 하면\n피자 조각을 얻을 수 있어요!")
        }
        .multilineTextAlignment(.center)
        .lineSpacing(10)
        .font(.pizzaBoldButtonTitle15)
        .foregroundColor(.secondary)
        .frame(width: .screenWidth - 50)
        .lineLimit(2)
        .padding(.top, 50)
        .padding(.bottom, .screenHeight * 0.1)
        .padding(.horizontal, 20)
    }
}
