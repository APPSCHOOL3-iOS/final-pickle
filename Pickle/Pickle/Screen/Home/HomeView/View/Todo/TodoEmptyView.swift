//
//  TodayTodoEmptyView.swift
//  Pickle
//
//  Created by 박형환 on 1/12/24.
//

import SwiftUI
import PickleCommon

struct TodoEmptyView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image("picklePizza")
                .resizable()
                .scaledToFit()
                .frame(width: .screenWidth - 200)
            
            Text("오늘 할일을 추가해 주세요!")
                .frame(maxWidth: .infinity)
                .font(.pizzaRegularSmallTitle)
        }
        .padding(.bottom)
    }
}

#Preview {
    TodoEmptyView()
}
