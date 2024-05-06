//
//  PizzaSummaryView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct TodayPizzaSummaryView: View {
    @Binding var todayPieceOfPizza: Int
    @Binding var pizzaSummarySheet: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("오늘 구운 피자")
                Spacer()
                Text("🍕")
                Text("x")
                Text("\(todayPieceOfPizza)")
                    .font(.pizzaBody)
                    .foregroundStyle(Color.pickle)
                Text("조각")
            }
            .padding([.horizontal, .vertical])
            .overlay(RoundedRectangle(cornerRadius: 20.0)
                .stroke(Color.secondary, lineWidth: 1))
            .onTapGesture {
                pizzaSummarySheet.toggle()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
}
