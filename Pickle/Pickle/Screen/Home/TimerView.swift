//
//  TimerView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var todoStore: TodoStore
    
    var todo: Todo
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var targetTime: TimeInterval = 1 // 목표소요시간
    @State private var timeRemaining: TimeInterval = 0 // 남은 시간
    @State private var spendTime: TimeInterval = 0 // 실제 소요시간
    @State private var timeExtra: TimeInterval = 0 // 추가소요시간
    @State private var settingTime: TimeInterval = 0 // 원형 타이머 설정용 시간
    // TODO: completeLimit 바꿔주기 (5분으로)
    @State private var completeLimit: TimeInterval = 10 // 5분 이후
    @State private var isDisabled: Bool = true // 완료버튼 활성화 용도
    
    @State private var isGiveupSign: Bool = false
    @State private var isShowGiveupAlert: Bool = false
    @State private var isDecresing: Bool = true // 목표시간 줄어드는
    @State private var isStart: Bool = true // 3,2,1,시작 보여줄지 아닐지
    @State private var isShowingReportSheet: Bool = false
    @State private var isComplete: Bool = false // '완료'버튼 누를때 시간 멈추기 확인용
    @Binding var isShowingTimerView: Bool

    var body: some View {
        VStack {
            // 멘트부분
            if isStart {
                Text("따라 읽어봐요!")
                    .font(.pizzaRegularTitle)
                    .padding(.top, 30)
                
                Text(" ")
                    .font(.pizzaBody)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                
            } else {
                Text(todo.content)
                    .font(.pizzaRegularTitle)
                    .padding(.top, 30)
                
                // TODO: RegisterView처럼 랜덤으로 바꿔주기
                Text("🍕 굽는 중")
                    .font(.pizzaBody)
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
            }
            // MARK: 타이머 부분
            ZStack {
                Circle()
                    .fill(.clear)
                    .frame(width: .screenWidth * 0.75)
                    .overlay(Circle().stroke(.tertiary, lineWidth: 5))
                Circle()
                    .trim(from: 0, to: progress())
                    .stroke(Color.pickle, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: .screenWidth * 0.75)
                    .rotationEffect(.degrees(-90))
                
                if isStart {
                    if timeRemaining != 0 {
                        Text(String(format: "%g", timeRemaining))
                            .foregroundColor(.pickle)
                            .font(.pizzaTimerNum)
                            .onReceive(timer) { _ in
                                timeRemaining -= 1
                            }
                    } else {
                        Text("시작")
                            .foregroundColor(.pickle)
                            .font(.pizzaTimerNum)
                            .onReceive(timer) { _ in
                                calcRemain()
                            }
                    }
                } else {
            
                    if isDecresing {
                        // 남은시간 줄어드는 타이머
                        Text(convertSecondsToTime(timeInSecond: timeRemaining))
                            .foregroundColor(.pickle)
                            .font(.pizzaTimerNum)
                            .onReceive(timer) { _ in
                                if !isComplete {
                                    timeRemaining -= 1
                                    spendTime += 1
                                    if timeRemaining == 0 {
                                        turnMode()
                                    }
                                    if spendTime >= completeLimit {
                                        isDisabled = false
                                    }
                                }
                            }
                    } else {
                        // 추가시간 늘어나는 타이머
                        HStack {
                            Text("+ \(convertSecondsToTime(timeInSecond: timeExtra))")
                                .foregroundColor(.pickle)
                                .font(.pizzaTimerNum)
                                .onReceive(timer) { _ in
                                    if !isStart && !isComplete {
                                        timeExtra += 1
                                        spendTime += 1
                                    }
                                }
                        }
                    }
                    
                    // 목표시간 명시
                    Text(convertTargetTimeToString(timeInSecond: todo.targetTime))
                        .font(.pizzaRegularSmallTitle)
                        .foregroundColor(.secondary)
                        .offset(y: 40)
                }
            }
            // MARK: 완료, 포기 버튼
            HStack {
                // TimerReportView Sheet 로 하기
                Button {
                    // TODO: spendTime 업데이트하기
                    if isDisabled {
                        isShowGiveupAlert = true
                        isComplete = true
                    } else {
                        updateDone(spendTime: spendTime)
                        isShowingReportSheet = true
                        isComplete = true
                    }
                } label: {
                    
                    Text("완료")
                        .font(.pizzaHeadline)
                        .frame(width: 75, height: 75)
                        .foregroundColor(.green)
                        .background(Color(hex: 0xDAFFD9))
                        .clipShape(Circle())
                }
                .disabled(isStart)
                .padding([.leading, .trailing], 75)
                
                Button(action: {
                    // 포기 alert띄우기
                    updateGiveup(spendTime: spendTime)
                    isGiveupSign = true
                    isShowGiveupAlert = true
                }, label: {
                    Text("포기")
                        .font(.pizzaHeadline)
                        .frame(width: 75, height: 75)
                        .foregroundColor(.red)
                        .background(Color(hex: 0xFFDBDB))
                        .clipShape(Circle())
                    
                })
                .disabled(isStart)
                .padding([.leading, .trailing], 75)
                
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .onAppear {
            startTodo()
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $isShowGiveupAlert) {
            if isDisabled && !isGiveupSign {
                Alert(title: Text("시작 후 5분은 피자조각을 얻지 못해요"),
                      message: Text(""),
                      primaryButton: .destructive(Text("완료")) {
                    isShowGiveupAlert = true
                    isShowingReportSheet = true
                }, secondaryButton: .cancel(Text("취소")) {
                    isComplete = false
                })

            } else {
                Alert(title: Text("정말 포기하시겠습니까?"),
                      message: Text("지금 포기하면 피자조각을 얻지 못해요"),
                      primaryButton: .destructive(Text("포기하기")) {
                    // 포기하기 함수
                    dismiss()
                }, secondaryButton: .cancel(Text("취소")) {
                    isGiveupSign = false
                })
            }
        }
        // TimerReportView Sheet로!
        .sheet(isPresented: $isShowingReportSheet) {
            TimerReportView(isShowingReportSheet: $isShowingReportSheet, isComplete: $isComplete, isShowingTimerView: $isShowingTimerView, todo: todo)
        }
    }
    
    func updateStart() {
        let todo = Todo(id: todo.id,
                        content: todo.content,
                        startTime: Date(),
                        targetTime: todo.targetTime,
                        spendTime: todo.spendTime,
                        status: .ongoing)
        todoStore.update(todo: todo)
    }
    
    func updateGiveup(spendTime: TimeInterval) {
        let todo = Todo(id: todo.id,
                        content: todo.content,
                        startTime: todo.startTime,
                        targetTime: todo.targetTime,
                        spendTime: spendTime,
                        status: .giveUp)
        todoStore.update(todo: todo)
    }
    
    func updateDone(spendTime: TimeInterval) {
        let todo = Todo(id: todo.id,
                        content: todo.content,
                        startTime: todo.startTime,
                        targetTime: todo.targetTime,
                        spendTime: spendTime,
                        status: .done)
        todoStore.update(todo: todo)
    }
    
    // TODO: 한시간 안넘어가면 분, 초 만 보여주기
    // 초 -> HH:MM:SS로 보여주기
    func convertSecondsToTime(timeInSecond: TimeInterval) -> String {
        let hours: Int = Int(timeInSecond / 3600)
        let minutes: Int = Int(timeInSecond - Double(hours) * 3600) / 60
        let seconds: Int = Int(timeInSecond.truncatingRemainder(dividingBy: 60))
        
        if timeInSecond >= 3600 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
    
    // 목표시간 초 -> H시간 M분으로 보여주기
    func convertTargetTimeToString(timeInSecond: TimeInterval) -> String {
        let hours: Int = Int(timeInSecond / 3600)
        let minutes: Int = Int(timeInSecond - Double(hours) * 3600) / 60
        
        if timeInSecond >= 3600 {
            return String(format: "%i시간 %i분", hours, minutes)
        } else {
            return String(format: "%i분", minutes)
        }
    }
    
    func startTodo() {
        self.settingTime = 3
        self.timeRemaining = settingTime
    }
    
    // TODO: data 구조보고 변수명 바꿔주기
    // 남은 시간 계산하기
    func calcRemain() {
        isStart = false
        updateStart()
        self.settingTime = todo.targetTime
        self.timeRemaining = settingTime
    }
    
    func turnMode() {
        self.isDecresing = false
    }
    
    func progress() -> CGFloat {
        if isStart {
            return CGFloat(0)
        } else {
            if isDecresing {
                return (CGFloat(settingTime - timeRemaining) / CGFloat(settingTime))
            } else {
                return 1
            }
        }
    }
}
    
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimerView(todo: Todo(id: UUID().uuidString,
                                 content: "이력서 작성하기",
                                 startTime: Date(),
                                 targetTime: 60,
                                 spendTime: 5400,
                                 status: .ready), isShowingTimerView: .constant(false))
                .environmentObject(TodoStore())
        }
    }
}
