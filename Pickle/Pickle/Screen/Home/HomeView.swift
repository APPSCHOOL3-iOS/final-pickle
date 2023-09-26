//
//  HomeView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

// TODO: 오늘 날짜 타이틀에 반영
// TODO: 아무것도 없을 때 어떻게 보여줄지
// TODO: 피자에 할일 진행도 반영
// TODO: 프로그래스바 문구 정리
// TODO: 할일 목록
// TODO: 할일 추가 버튼

import SwiftUI

struct HomeView: View {
    @State private var goalProgress: Double = 0.0
    @State private var userTotalPizza: Int = 0 // 사용자 프로퍼티로 추가 필요
    let goalTotal: Double = 8
        
    var body: some View {
        ScrollView {
            CircleView(slices: Int(goalProgress))
                .frame(width: 200, height: 200)
            
            // MARK: 테스트용, 추후 삭제
            Button("할일 완료") {
                if goalProgress < 8 {
                    withAnimation {
                        goalProgress += 1
                    }
                } else {
                    userTotalPizza += 1
                    goalProgress = 0
                }
            }
            
            VStack(spacing: 8) {
                Text("\(Int(goalProgress)) / \(Int(goalTotal))")
                    .font(.pizzaTitleBold)
                
                Text("첫 피자를 만들어볼까요?")
                    .font(.pizzaHeadline)
                
                ProgressView(value: goalProgress, total: goalTotal)
                    .progressViewStyle(LinearProgressViewStyle(tint: .black))
                    .padding()
            }
            .padding(.horizontal)
            
            ForEach(0..<5) { _ in
                TodoCellView()
                    .onTapGesture {
                        // TODO: 할일 추가 Sheet로 올릴지?
                    }
            }
        }
        .navigationTitle("9월 25일 월요일")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    // TODO: MissionView 연결
                } label: {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}
