//
//  TodayPizzaSheetView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct TodayPizzaSheetView: View {
    
    var currentDay: Date
    var todayPieceOfPizza: Int
    var walkMission: Int
    var todayCompletedTasks: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 25) {
                HStack {
                    Text("\(currentDay.format("M월 d일"))" + " 피자 🍕")
                        .font(.nanumBd)
                }
                Divider()
                
                HStack {
                    Text("✅")
                    Text("오늘 할일 완료")
                    Spacer()
                    Text("x" + " \(todayCompletedTasks)")
                }
                .font(.nanumRg)
                
                HStack {
                    Text("🏃")
                    Text("걷기 미션 완료")
                    Spacer()
                    Text("x" + " \(walkMission)")
                }
                .font(.nanumRg)
                
                HStack {
                    Text("☀️")
                    Text("기상 미션 완료")
                    Spacer()
                    Text("(곧 공개될 예정이에요!)")
                        .font(.callout)
                }
                .font(.nanumRg)
                
                Divider()
                HStack {
                    Text("Total Pizza")
                    Spacer()
                    Text("\(todayPieceOfPizza)" + " 조각")
                        .foregroundStyle(Color.pickle)
                }
                .font(.nanumBd)
                Divider()
                Spacer()
                
            }
            .padding()
        }
    }
}
