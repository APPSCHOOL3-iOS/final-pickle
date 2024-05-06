//
//  TestGesture.swift
//  Pickle
//
//  Created by 박형환 on 10/15/23.
//

import SwiftUI

struct CustomSheetView<Content: View>: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var navigationStore: NavigationStore
    
    // Gesture properties
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    
    @GestureState private var gestureOffset: CGFloat = 0
    @State private var yVelocity: Double = 0.0
    @State private var previousDragValue: DragGesture.Value?
    
    @ViewBuilder let content: () -> Content
    
    private let defaultHeight: CGFloat = CGFloat.screenHeight / 3
    private let defaultMidHeight: CGFloat = CGFloat.screenHeight / 2 - 80
    private let defaultTopHeight: CGFloat = 0
    
    init( content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        ZStack {
            // For getting height for drag gesture
            GeometryReader { _ -> AnyView in
                // let height = proxy.frame(in: .global).height
                let yOffset_height: CGFloat = defaultMidHeight
                return AnyView(
                    ZStack {
                        Theme.colorMode(colorScheme)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                        
                        VStack {
                            Capsule()
                                .fill(Theme.colorMode2(colorScheme))
                                .frame(width: 60, height: 4)
                                .padding(.top, 10)
                            
                            content()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                    }
                        .offset(y: yOffset_height)
                        .offset(y: calaculate(height: yOffset_height))
                        .gesture(
                            DragGesture()
                                .updating($gestureOffset) { value, state, _ in
                                    state = dragGestureBody(value)
                                }
                                .onChanged { value in onChangedOffset(value) }
                                .onEnded { _ in onEndedOffset(yOffset_height) }
                        )
                )
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
    
    func calaculate(height: CGFloat) -> CGFloat {
        -offset > 0 ? -offset <= (height) ? offset : -(height) : offset
    }
    
    private func dragGestureBody(_ value: DragGesture.Value) -> CGFloat {
        // save previous value
        DispatchQueue.main.async {
            self.previousDragValue = value
        }
        return value.translation.height
    }
    
    private func onChangedOffset(_ value: GestureStateGesture<DragGesture, CGFloat>.Value) {
        self.offset = gestureOffset + lastOffset
        if let previousValue = self.previousDragValue {
            // 계산 velocity using currentValue and previousValue
            let ( _, yOffset) = self.calcDragVelocity(previousValue: previousValue,
                                                      currentValue: value)
            self.yVelocity = yOffset
        }
    }
    
    private func onEndedOffset(_ yOffset_height: CGFloat) {
        let maxHeight = yOffset_height
        withAnimation {
            // 탑
            if -offset > maxHeight / 2 {
                offset = -maxHeight
            } else {
                // 바텀
                if offset > 120 {
                    withAnimation {
                        navigationStore.dismiss(home: .isPizzaSeleted(false))
                    }
                }
                offset = 0
            }
        }
        // Storing last offset, so that the gesture can continue from the last position
        lastOffset = offset
    }
    
    func calcDragVelocity(previousValue: DragGesture.Value, currentValue: DragGesture.Value) -> (Double, Double) {
        let timeInterval = currentValue.time.timeIntervalSince(previousValue.time)
        
        let diffXInTimeInterval = Double(currentValue.translation.width - previousValue.translation.width)
        let diffYInTimeInterval = Double(currentValue.translation.height - previousValue.translation.height)
        
        let velocityX = diffXInTimeInterval / timeInterval
        let velocityY = diffYInTimeInterval / timeInterval
        return (velocityX, velocityY)
    }
    
    // Blur radius for background
    func getBlurRadius() -> CGFloat {
        let progress = -offset / (UIScreen.main.bounds.height - 100)
        return progress * 30
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
    }
}
