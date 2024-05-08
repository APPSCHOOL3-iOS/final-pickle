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
    @EnvironmentObject var timerVM: TimerViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    
    var todo: Todo
    
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
    @Binding var isShowingTimerView: Bool
    @State private var wiseSaying: String = ""
    @AppStorage(STORAGE.isRunTimer.id) var isRunTimer: Bool = false
    @AppStorage(STORAGE.backgroundNumber.id) var backgroundNumber: Int = 0
    @AppStorage(STORAGE.todoId.id) var todoId: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                TimerTitleView(isStart: $state.isStart, todo: todo)
                    .offset(y: -(.screenWidth * 0.80))
            }
            
            // MARK: 타이머 부분
            CircleTimerView(todo: todo,
                            state: $state,
                            isRunTimer: $isRunTimer,
                            backgroundNumber: $backgroundNumber)
                .offset(y: -(.screenWidth * 0.18))
        
            // MARK: 완료, 포기 버튼
            TimerCompleteButton(todo: todo,
                                state: $state,
                                isRunTimer: $isRunTimer,
                                backgroundNumber: $backgroundNumber)
                .offset(y: .screenWidth * 0.75 / 2 - 10 )
            
            VStack {
                Spacer()
                if state.isDisabled && !state.isStart {
                    completeDiscription
                } else if !state.isDisabled && !state.isStart {
                    wiseSayingView
                }
            }
            .offset(y: .screenWidth * 0.08 )
        }
        .onAppear { startTodo() }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $state.isShowingReportSheet) {
            TimerReportView(isShowingReportSheet: $state.isShowingReportSheet,
                            isShowingTimerView: $isShowingTimerView,
                            todo: timerVM.todo)
                .interactiveDismissDisabled()
        }
        .showGiveupAlert(isPresented: $state.showingAlert,
                         title: "포기하시겠어요?",
                         contents: "지금 포기하면 피자조각을 얻지 못해요",
                         primaryButtonTitle: "포기하기",
                         primaryAction: updateGiveup,
                         primaryparameter: timerVM.spendTime,
                         secondaryButton: "돌아가기",
                         secondaryAction: giveupSecondary,
                         externalTapAction: giveupSecondary)
    }
    
    func giveupSecondary() {
        state.isGiveupSign = false
        state.isComplete = false
    }
    
    // 포기시 업데이트, status giveup으로
    func updateGiveup(spendTime: TimeInterval) {
        let todo = Todo(id: todo.id,
                        content: todo.content,
                        startTime: state.realStartTime,
                        targetTime: todo.targetTime,
                        spendTime: spendTime,
                        status: .giveUp)
        todoStore.update(todo: todo)
        timerVM.updateTodo(spendTime: spendTime, status: .giveUp)
        isRunTimer = false

        backgroundNumber = 0
        
        if spendTime < todo.targetTime {
            notificationManager.removeSpecificNotification(id: [todo.id])
        }
        state.isShowingReportSheet = true
    }
    
    func convertSecondsToTime(timeInSecond: TimeInterval) -> String {
        Date.convertSecondsToTime(timeInSecond: timeInSecond)
    }
    
    // 목표시간 초 -> H시간 M분으로 보여주기
    func convertTargetTimeToString(timeInSecond: TimeInterval) -> String {
        Date.convertTargetTimeToString(timeInSecond: timeInSecond)
    }
    
    func startTodo() {
        state.settingTime = 3
        timerVM.timeRemaining = state.settingTime
        timerVM.makeRandomSaying()
        timerVM.fetchTodo(todo: todo)
        todoId = todo.id
    }
}

extension TimerView {
    private var completeDiscription: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("최소 5분 할 일을 하면\n피자 조각을 얻을 수 있어요!")
        }
        .multilineTextAlignment(.center)
        .lineSpacing(10)
        .font(.pizzaBoldButtonTitle15)
        .foregroundColor(.secondary)
        .frame(width: .screenWidth - 50)
        .lineLimit(2)
        .padding(.top, 50)
        .padding(.bottom, .screenHeight * 0.1)
        .padding(.horizontal, 20)
    }
    
    private var wiseSayingView: some View {
        Text("\(timerVM.wiseSaying)")
            .multilineTextAlignment(.center)
            .lineSpacing(10)
            .font(.pizzaBoldButtonTitle15)
            .foregroundColor(.secondary)
            .frame(width: .screenWidth - 50)
            .lineLimit(4)
            .minimumScaleFactor(0.7)
            .padding(.top, 50)
            .padding(.bottom, .screenHeight * 0.1)
            .padding(.horizontal, 20)
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimerView(todo: Todo(id: UUID().uuidString,
                                 content: "이력서 작성하기dfs",
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
