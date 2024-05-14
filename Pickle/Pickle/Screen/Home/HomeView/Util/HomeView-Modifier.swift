//
//  HomeView-extension.swift
//  Pickle
//
//  Created by 박형환 on 11/7/23.
//

import SwiftUI

extension HomeView {
    struct SheetModifier: ViewModifier {
        @GestureState private var offset = CGSize.zero
        
        @Binding var selection: PizzaSelectedView.Selection
        
        func body(content: Content) -> some View {
            content
                .overlay {
                    if selection.isPizzaSelected {
                        // For getting frame for image
                        GeometryReader { proxy in
                            let frame = proxy.frame(in: .global)
                            Color.black
                                .opacity(0.3)
                                .frame(width: frame.width, height: frame.height)
                        }
                        .ignoresSafeArea()
                        
                        CustomSheetView {
                            PizzaSelectedView(selection: $selection)
                        }.transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .toolbar(selection.isPizzaSelected ? .hidden : .visible, for: .tabBar)
        }
    }
    
    struct FullScreenCoverModifier: ViewModifier {
        @Binding var selection: UpdateTodoView.Selection
        func body(content: Content) -> some View {
            content
                .fullScreenCover(isPresented: $selection.isShowing) {
                UpdateTodoView(selection: $selection)
            }
        }
    }
    
    struct TimerViewModifier: ViewModifier {
        @Binding var selection: TodoCellView.Selection
        
        func body(content: Content) -> some View {
            content
                .fullScreenCover(isPresented: $selection.isShowingTimer) {
                    TimerView(receiveTodo: selection.selectedTodo,
                              isShowingTimerView: $selection.isShowingTimer)
                }
        }
    }
}
