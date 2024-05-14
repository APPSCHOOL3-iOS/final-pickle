//
//  PizzaSummaryView.swift
//  Pickle
//
//  Created by kaikim on 2023/10/18.
//

import SwiftUI
import PickleCommon

struct PizzaSummaryView: View {
    
    @EnvironmentObject private var todoStore: TodoStore
    @EnvironmentObject private var userStore: UserStore
    
    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var myTotalPizza: Int {
        return userStore.pizzaCount * 8 + Int(userStore.pizzaSlice)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack(alignment: .leading) {
                    HStack(spacing: 15) {
                        myPizzaView()
                            .modifier(PizzaSummaryModifier())
                        
                        myPieceOfPizzaView()
                            .modifier(PizzaSummaryModifier())
                    }
                    .padding(.horizontal)
            
                    myTotalSpendTimeForPizzaView()
                        .modifier(PizzaSummaryModifier())
                        .padding(.horizontal)
                    
                    myPizzaCollectionView()
                        .modifier(PizzaSummaryModifier())
                        .padding(.horizontal)
                }
            }
            .task {
                await todoStore.fetch()
            }
        }
        .navigationTitle("통계")
    }
    
    // MARK: - 나의 피자
    func myPizzaView() -> some View {
        HStack {
            VStack(alignment: .center, spacing: 8) {
                Text("완성한 피자")
                Text("\(userStore.pizzaCount) 판")
                    .foregroundStyle(Color.pickle)
            }
        }
    }
    
    // MARK: - 나의 피자 조각
    func myPieceOfPizzaView() -> some View {
        HStack {
            VStack(alignment: .center, spacing: 8) {
                Text("구운 피자 조각")
                    .lineLimit(1)
                Text("\(myTotalPizza) 조각")
                    .foregroundStyle(Color.pickle)
            }
        }
    }
    
    // MARK: - 피자 구운시간이 아니라 집중한 시간 -> SpendTime 활용하기, 시간이 왔다갔다 난리도 안임
    func myTotalSpendTimeForPizzaView() -> some View {
        HStack {
            VStack(alignment: .center, spacing: 8) {
                
                Text("피자 구운 시간")
                let tempResult = todoStore.todos.map { $0.spendTime }.reduce(0) { $0 + $1 }
                let finalSpendTime = convertSecondsToTime(timeInSecond: tempResult)
                Text("\(finalSpendTime)")
                    .foregroundStyle(Color.pickle)
            }
        }
    }
    
    // MARK: - 피자 컬렉션
    func myPizzaCollectionView() -> some View {
        VStack {
            Text("피자 컬렉션")
            LazyVGrid(columns: columns) {
                 ForEach(userStore.user.currentPizzas.compactMap(\.pizza)) { pizza in
                     PizzaCollectionView(pizza: .constant(pizza),
                                         currentPizza: .constant(.defaultPizza) )
                         .frame(width: CGFloat.screenWidth / 3 - 40)
                         .padding(.horizontal, 10)
                 }
            }
        }
    }
    
    func convertSecondsToTime(timeInSecond: Double) -> String {
        let hours: Int = Int(timeInSecond / 3600)
        let minutes: Int = Int(timeInSecond - Double(hours) * 3600) / 60
        let seconds: Int = Int(timeInSecond.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%02i시간 %02i분 %02i초", hours, minutes, seconds)
    }
}

struct PizzaSummaryModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.nanumEb)
            .padding(.vertical, 17)
            .background(.clear)
            .frame(minWidth: 0, maxWidth: .infinity)
            .cornerRadius(20.0)
            .overlay(RoundedRectangle(cornerRadius: 20.0)
                .stroke(Color(.lightGray), lineWidth: 1))
            .padding(.top, 8)
            .minimumScaleFactor(0.1)
    }
}

#Preview {
    NavigationStack {
        PizzaSummaryView()
            .environmentObject(TodoStore())
            .environmentObject(UserStore())
    }
}
