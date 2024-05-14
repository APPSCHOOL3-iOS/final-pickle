//
//  TodayTodoEmptyView.swift
//  Pickle
//
//  Created by 박형환 on 1/12/24.
//

import SwiftUI
import Lottie
import PickleCommon

struct TodoEmptyView: View {
    
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(spacing: 16) {
            if scheme == .light {
                LottieView(
                    animation: .named("PizzaPickle")
                )
                .playing(loopMode: .loop)
                .resizable()
                .scaledToFit()
                .frame(width: .screenWidth - 200)
            } else {
                Image("picklePizza")
                    .resizable()
                    .scaledToFit()
                    .frame(width: .screenWidth - 200)
            }
  
            Text("오늘 할일을 추가해 주세요!")
                .frame(maxWidth: .infinity)
                .font(.pizzaRegularSmallTitle)
        }
    }
}

#Preview {
    TodoEmptyView()
}
