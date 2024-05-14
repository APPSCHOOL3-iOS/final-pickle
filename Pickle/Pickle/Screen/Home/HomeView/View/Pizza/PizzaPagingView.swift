//
//  PizzaPagingView.swift
//  Pickle
//
//  Created by 박형환 on 11/18/23.
//

import SwiftUI
import PickleCommon

struct PizzaPagingView: View {
    
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var userStore: UserStore
    
    var routing: () -> Void
    
    init(routing: @autoclosure @escaping () -> Void) {
        self.routing = routing
    }
    
    var body: some View {
        pizzaPagingView
    }
    
    enum ScrollPizzaID: Identifiable, Hashable {
        var id: Self {
            self
        }
        case pizza(String)
    }
    
    private var btnFrame: CGFloat {
        30
    }
    private var btnPadding: CGFloat {
        8
    }
    private var pagePadding: CGFloat {
        (btnFrame * 2) + (btnPadding * 4)
    }
    
    private var pizzaPagingView: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                LazyHStack {
                    TabView(selection: $viewModel.pizzaPosition) {
                        ForEach(Array(zip(userStore.user.currentPizzas,
                                          userStore.user.currentPizzas.indices)),
                                id: \.1) { currentPizza in
                            ZStack {
                                makePizzaView(currentPizza: currentPizza.0)
                            }
                            .fixSize(geo, diffX: -pagePadding)
                            .tag(ScrollPizzaID.pizza(currentPizza.0.pizza!.id))
                        }.padding(.bottom, 10)
                            .padding(.top, -10)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .fixSize(geo, diffY: 30)
                }
                .onAppear {
                    viewModel.pizzaScrollViewWidth = geo.size.width - pagePadding
                    setupAppearance()
                }
            }.fixSize(geo)
        }
        .scrollIndicators(.hidden)
    }
    
    private func makePizzaView(currentPizza: CurrentPizza) -> some View {
        PizzaView(
            currentPizza: currentPizza
        )
        .frame(width: CGFloat.screenWidth / 2,
               height: CGFloat.screenWidth / 2)
        .padding()
        .onTapGesture {
            withAnimation {
                routing()
            }
        }
    }
    
    private func setupAppearance() {
        let color = UIColor(Color.pickle)
        UIPageControl.appearance().currentPageIndicatorTintColor = color
        UIPageControl.appearance().pageIndicatorTintColor = color.withAlphaComponent(0.3)
    }
}
