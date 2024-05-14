//
//  TimerView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var pizzaTaskActivity: PizzaLiveActivity
    
    var receiveTodo: Todo
    
    struct TimerState: Equatable {
        var isStart: Bool = true
        var isComplete: Bool = false
        var isDisabled: Bool = true
        var isGiveupSign: Bool = false
        var realStartTime: Date = Date()
        var settingTime: TimeInterval = 0
        var isShowingReportSheet: Bool = false
        var isShowGiveupAlert: Bool = false
        var showingAlert: Bool = false
    }
    
    @State private var state: TimerState = TimerState()
    @State private var wiseSaying: String = ""
    @Binding var isShowingTimerView: Bool
    
    @AppStorage(STORAGE.isRunTimer.id, store: .group)
    var isRunTimer: Bool = false
    
    @AppStorage(STORAGE.backgroundNumber.id, store: .group)
    var backgroundNumber: Int = 0
    
    @AppStorage(STORAGE.todoId.id, store: .group)
    var todoId: String = ""
    
    var body: some View {
        ZStack {
            TimerTitleView(
                isStart: $state.isStart,
                todo: receiveTodo
            )
            .equatable()
            .offset(y: -(.screenWidth * 0.80))
            
            // MARK: 타이머 부분
            CircleTimerView(
                todo: receiveTodo,
                state: $state,
                isRunTimer: $isRunTimer,
                backgroundNumber: $backgroundNumber
            )
            .offset(y: -(.screenWidth * 0.18))
            
            // MARK: 완료, 포기 버튼
            TimerCompleteButton(state: $state) { type in
                endActivity(type)
            }
            .equatable()
            .offset(y: .screenWidth * 0.75 / 2 - 10 )
            
            VStack {
                Spacer()
                BottomDescriptionView(
                    isStart: state.isStart,
                    isDisabled: state.isDisabled,
                    wiseSaying: timerViewModel.wiseSaying
                )
            }
            .offset(y: .screenWidth * 0.08 )
        }
        .onAppear { startTodo() }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $state.isShowingReportSheet) {
            TimerReportView(
                isShowingReportSheet: $state.isShowingReportSheet,
                isShowingTimerView: $isShowingTimerView,
                todo: timerViewModel.todo
            )
            .interactiveDismissDisabled()
        }
        .showGiveupAlert(
            isPresented: $state.showingAlert,
            title: "포기하시겠어요?",
            contents: "지금 포기하면 피자조각을 얻지 못해요",
            primaryButtonTitle: "포기하기",
            primaryAction: updateGiveup,
            primaryparameter: timerViewModel.spendTime,
            secondaryButton: "돌아가기",
            secondaryAction: giveupSecondary,
            externalTapAction: giveupSecondary
        )
    }
    
    private func giveupSecondary() {
        state.isGiveupSign = false
        state.isComplete = false
    }
    
    
    /// 완료 + 피자겟챠
    private func updateDone(spendTime: TimeInterval) {
        let todo = receiveTodo
            .update(path: \.startTime, to: state.realStartTime)
            .update(path: \.spendTime, to: spendTime)
            .update(path: \.status, to: TodoStatus.done)
        
        todoStore.update(todo: todo)
        timerViewModel.updateTodo(spendTime: spendTime, status: .done)
        isRunTimer = false
        backgroundNumber = 0
        
        do {
            try userStore.addPizzaSlice(slice: 1)
        } catch {
            Log.error("❌피자 조각 추가 실패❌")
        }
        
        if spendTime < todo.targetTime {
            todoStore.deleteNotificaton(todo: todo, noti: notificationManager)
        }
    }
    
    /// 포기시 업데이트, status giveup으로
    private func updateGiveup(spendTime: TimeInterval) {
        let todo = receiveTodo
            .update(path: \.startTime, to: state.realStartTime)
            .update(path: \.spendTime, to: spendTime)
            .update(path: \.status, to: TodoStatus.giveUp)
        
        todoStore.update(todo: todo)
        timerViewModel.updateTodo(spendTime: spendTime, status: .giveUp)
        isRunTimer = false
        backgroundNumber = 0
        
        if spendTime < todo.targetTime {
            notificationManager.removeSpecificNotification(id: [todo.id])
        }
        state.isShowingReportSheet = true
    }
    
    private func convertSecondsToTime(timeInSecond: TimeInterval) -> String {
        Date.convertSecondsToTime(timeInSecond: timeInSecond)
    }
    
    // 목표시간 초 -> H시간 M분으로 보여주기
    private func convertTargetTimeToString(timeInSecond: TimeInterval) -> String {
        Date.convertTargetTimeToString(timeInSecond: timeInSecond)
    }
    
    private func startTodo() {
        state.settingTime = 3
        timerViewModel.timeRemaining = state.settingTime
        timerViewModel.makeRandomSaying()
        timerViewModel.fetchTodo(todo: receiveTodo)
        todoId = receiveTodo.id
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimerView(receiveTodo: Todo(id: UUID().uuidString,
                                        content: "이력서 작성하기",
                                        startTime: Date(),
                                        targetTime: 15,
                                        spendTime: 5400,
                                        status: .ready), isShowingTimerView: .constant(false))
            .environmentObject(TodoStore())
            .environmentObject(TimerViewModel())
            .environmentObject(UserStore())
            .environmentObject(NotificationManager(mediator: NotiMediator()))
        }
    }
}
