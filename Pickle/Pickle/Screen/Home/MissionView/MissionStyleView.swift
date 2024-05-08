//
//  MissionStyle.swift
//  Pickle
//
//  Created by Suji Jang on 2023/09/25.
//

import SwiftUI
import HealthKit

struct MissionButton: View {
    @Binding var status: Status
    
    var buttonTitle: String {
        switch status {
        case .ready:
            return "피자 대기"
        case .complete:
            return "피자 받기"
        case .done:
            return "획득 완료"
        case .fail:
            return "미션 실패"
        default:
            return "피자"
        }
    }
    
    var buttonTitleColor: Color {
        switch status {
        case .ready, .complete:
            return .white
        case .done, .fail:
            return .secondary
        default:
            return .black
        }
    }
    
    var buttonColor: Color {
        switch status {
        case .ready, .complete:
            return .pickle
        case .done, .fail:
            return Color(UIColor.secondarySystemBackground)
        default:
            return .white
        }
    }
    
    var buttonOpacity: Double {
        switch status {
        case .ready:
            return 0.4
        case .complete, .done, .fail:
            return 1
        default:
            return 1
        }
    }
    
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                Text(buttonTitle)
                    .font(.pizzaBoldButtonTitle)
                    .foregroundColor(buttonTitleColor)
            }
            .frame(width: 60, height: 3)
            .padding()
            .background(buttonColor)
            .opacity(buttonOpacity)
            .cornerRadius(10.0)
        }
    }
}

struct PizzaTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 35))
            .background(
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .scaleEffect(1.6))
    }
}

struct BehaviorMissionStyleView: View {
    @EnvironmentObject var missionStore: MissionStore
    @EnvironmentObject var userStore: UserStore
    @State private var isBehaviorMissionSettingModalPresented = false
    
    private var stepCount: Int {
        guard let tempCount = healthKitStore.stepCount else {return 0}
        return tempCount
    }
    @Binding var behaviorMission: BehaviorMission
    @Binding var showsAlert: Bool
    var healthKitStore: HealthKitStore
    
    var buttonSwitch1: Bool {
        switch behaviorMission.status {
        case .ready, .done:
            return true
        case .complete:
            return false
        default:
            return false
        }
    }
    var buttonSwitch2: Bool {
        switch behaviorMission.status1 {
        case .ready, .done:
            return true
        case .complete:
            return false
        default:
            return false
        }
    }
    var buttonSwitch3: Bool {
        switch behaviorMission.status2 {
        case .ready, .done:
            return true
        case .complete:
            return false
        default:
            return false
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(behaviorMission.title)
                    .font(.nanumEbTitle)
                    .bold()
                    .padding(.bottom, 4)
                Spacer()
            }
            
            HStack {
                if healthKitStore.stepCount != nil {
                    
                    Text("현재 \(stepCount) 걸음")
                        .font(.pizzaBody)
                        .foregroundColor(.textGray)
                } else {
                    Text("현재 0 걸음")
                        .font(.pizzaBody)
                        .foregroundColor(.textGray)
                }
                
                Spacer()
                
            }
            
            HStack(spacing: (.screenWidth - 252) / 8) {
                VStack(alignment: .center) {
                    Text("🍕")
                        .modifier(PizzaTextModifier())
                        .padding()
                    
                    Text("1,000걸음")
                        .font(.pizzaBoldButtonTitle)
                        .bold()
                        .padding(.vertical, 3)
                    
                    MissionButton(status: $behaviorMission.status) {
                        
                        behaviorMission.status = .done
                        
                        missionStore.update(mission: 
                                .behavior(
                                    BehaviorMission(id: behaviorMission.id,
                                                    title: behaviorMission.title,
                                                    status: .done,
                                                    status1: behaviorMission.status1,
                                                    status2: behaviorMission.status2)
                                )
                        )
                        withAnimation {
                            do {
                                try userStore.addPizzaSlice(slice: 1)
                            } catch {
                                Log.error("❌피자 조각 추가 실패❌")
                            }
                        }
                        showsAlert = true
                    }
                    .disabled(buttonSwitch1)
                }
                
                VStack(alignment: .center) {
                    Text("🍕")
                        .modifier(PizzaTextModifier())
                        .padding()
                    
                    Text("5,000걸음")
                        .font(.pizzaBoldButtonTitle)
                        .bold()
                        .padding(.vertical, 3)
                    
                    MissionButton(status: $behaviorMission.status1) {
                        behaviorMission.status1 = .done
                        
                        missionStore.update(mission: 
                                .behavior(
                                    BehaviorMission(id: behaviorMission.id,
                                                    title: behaviorMission.title,
                                                    status: behaviorMission.status,
                                                    status1: .done,
                                                    status2: behaviorMission.status2)
                                )
                        )
                        withAnimation {
                            do {
                                try userStore.addPizzaSlice(slice: 1)
                            } catch {
                                Log.error("❌피자 조각 추가 실패❌")
                            }
                        }
                        showsAlert = true
                    }
                    .disabled(buttonSwitch2)
                }
                VStack(alignment: .center) {
                    Text("🍕")
                        .modifier(PizzaTextModifier())
                        .padding()
                    
                    Text("10,000걸음")
                        .font(.pizzaBoldButtonTitle)
                        .bold()
                        .padding(.vertical, 3)
                    
                    MissionButton(status: $behaviorMission.status2) {
                        behaviorMission.status2 = .done
                        
                        missionStore.update(mission: .behavior(BehaviorMission(id: behaviorMission.id,
                                                                               title: behaviorMission.title,
                                                                               status: behaviorMission.status,
                                                                               status1: behaviorMission.status1,
                                                                               status2: .done)))
                        withAnimation {
                            do {
                                try userStore.addPizzaSlice(slice: 1)
                            } catch {
                                Log.error("❌피자 조각 추가 실패❌")
                            }
                        }
                        showsAlert = true
                    }
                    .disabled(buttonSwitch3)
                }
            }
        }
        
        .onChange(of: healthKitStore.stepCount) { _ in
            self.missionComplete()
        }
        
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.clear)
        .frame(width: .screenWidth - 32)
        .cornerRadius(20.0)
        .overlay(RoundedRectangle(cornerRadius: 20.0)
            .stroke(Color(.lightGray), lineWidth: 1))
        .padding(.horizontal)
        .padding(.top, 15)
    }
    
    func missionComplete() {
        if let stepCount = healthKitStore.stepCount {
            if behaviorMission.status != .done {
                if stepCount >= 1000 {
                    behaviorMission.status = .complete
                    missionStore.update(mission: .behavior(BehaviorMission(id: behaviorMission.id,
                                                                           title: behaviorMission.title,
                                                                           status: .complete,
                                                                           status1: behaviorMission.status1,
                                                                           status2: behaviorMission.status2)))
                }
            }
            if behaviorMission.status1 != .done {
                if stepCount >= 5000 {
                    behaviorMission.status1 = .complete
                    missionStore.update(mission: .behavior(BehaviorMission(id: behaviorMission.id,
                                                                           title: behaviorMission.title,
                                                                           status: behaviorMission.status,
                                                                           status1: .complete,
                                                                           status2: behaviorMission.status2)))
                }
            }
            if behaviorMission.status2 != .done {
                if stepCount >= 10000 {
                    behaviorMission.status2 = .complete
                    missionStore.update(mission: .behavior(BehaviorMission(id: behaviorMission.id,
                                                                           title: behaviorMission.title,
                                                                           status: behaviorMission.status,
                                                                           status1: behaviorMission.status1,
                                                                           status2: .complete)))
                }
            }
        }
        
    }
}

struct MissionStyle_Previews: PreviewProvider {
    static var previews: some View {
        //        TimeMissionStyleView(timeMission: .constant(TimeMission(id: "")), showsAlert: .constant(false), showSuccessAlert: .constant(false))
        //            .environmentObject(MissionStore())
        //            .environmentObject(UserStore())
        BehaviorMissionStyleView(behaviorMission: .constant(BehaviorMission(id: "",
                                                                            title: "",
                                                                            status: .ready,
                                                                            status1: .ready,
                                                                            status2: .ready,
                                                                            date: Date())),
                                 showsAlert: .constant(false),
                                 healthKitStore: HealthKitStore())
        .environmentObject(MissionStore())
        .environmentObject(UserStore())
        MissionView()
            .environmentObject(MissionStore())
            .environmentObject(UserStore())
    }
}

// 기상미션 주석처리
//  struct TimeMissionStyleView: View {
//    @EnvironmentObject var missionStore: MissionStore
//    @EnvironmentObject var userStore: UserStore
//    @Binding var timeMission: TimeMission
//
//    @AppStorage(STORAGE.is24HourClock.id) var is24HourClock: Bool = true
//    @AppStorage(STORAGE.timeFormat.id) var timeFormat: String = "HH:mm"
//
//    @State private var showTimeMissionModal = false
//    @Binding var showsAlert: Bool
//    @Binding var showSuccessAlert: Bool
//
//    var buttonSwitch: Bool {
//        switch timeMission.status {
//        case .ready, .done, .fail:
//            return true
//        case .complete:
//            return false
//        default:
//            return false
//        }
//    }
//
//    var body: some View {
//        HStack(alignment: .bottom) {
//            VStack(alignment: .leading) {
//                Text(timeMission.title)
//                    .font(.nanumEbTitle)
//                    .foregroundColor(.primary)
//                    .padding(.bottom, 1)
//
//                Button(action: {
//                    showTimeMissionModal.toggle()
//                }, label: {
//                    HStack {
//                        Text("\(timeMission.changeWakeupTime.format(timeFormat))")
//                            .font(.pizzaTitle2)
//
//                        Image(systemName: "chevron.up.chevron.down")
//                    }
//                    .foregroundColor(.secondary)
//                })
//                .sheet(isPresented: $showTimeMissionModal) {
//                    TimeMissionSettingView(timeMission: $timeMission,
//                                           title: timeMission.title,
//                                           showTimeMissionModal: $showTimeMissionModal,
//                                          showSuccessAlert: $showSuccessAlert)
//                    .presentationDetents([.fraction(0.4)])
//                }
//            }
//
//            Spacer(minLength: 10)
//
//            MissionButton(status: $timeMission.status, action: {
//                timeMission.status = .done
//                missionStore.update(mission: .time(TimeMission(id: timeMission.id,
//                                                               title: timeMission.title,
//                                                               status: .done,
//                                                               date: timeMission.date,
//                                                               wakeupTime: timeMission.wakeupTime,
//                                                               changeWakeupTime: timeMission.changeWakeupTime)))
//                withAnimation {
//                    do {
//                        try userStore.addPizzaSlice(slice: 1)
//
//                    } catch {
//                        Log.error("❌피자 조각 추가 실패❌")
//                    }
//                }
//                showsAlert = true
//            })
//            .disabled(buttonSwitch)
//        }
//        .onAppear {
//            missionComplete()
//        }
//        .refreshable {
//            missionComplete()
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 20)
//        .background(.clear)
//        .frame(minWidth: 0, maxWidth: .infinity)
//        .cornerRadius(20.0)
//        .overlay(RoundedRectangle(cornerRadius: 20.0)
//            .stroke(Color(.lightGray), lineWidth: 1))
//        .padding(.horizontal)
//        .padding(.top, 15)
//    }
//
//    func missionComplete() {
//        // 현재 시간과 목표 기상시간 비교 .ready .complete .done .fail
//        if Date() >= timeMission.wakeupTime.adding(minutes: -10)
//            && Date() <= timeMission.wakeupTime.adding(minutes: 10) {
//            if timeMission.status != .done {
//                timeMission.status = .complete
//                missionStore.update(mission: .time(TimeMission(id: timeMission.id,
//                                                               title: timeMission.title,
//                                                               status: .complete,
//                                                               date: timeMission.date,
//                                                               wakeupTime: timeMission.wakeupTime,
//                                                               changeWakeupTime: timeMission.changeWakeupTime)))
//            }
//        } else if Date() < timeMission.wakeupTime.adding(minutes: -10) {
//            timeMission.status = .ready
//            missionStore.update(mission: .time(TimeMission(id: timeMission.id,
//                                                           title: timeMission.title,
//                                                           status: .ready,
//                                                           date: timeMission.date,
//                                                           wakeupTime: timeMission.wakeupTime,
//                                                           changeWakeupTime: timeMission.changeWakeupTime)))
//        } else {
//            timeMission.status = .fail
//            missionStore.update(mission: .time(TimeMission(id: timeMission.id,
//                                                            title: timeMission.title,
//                                                            status: .fail,
//                                                            date: timeMission.date,
//                                                            wakeupTime: timeMission.wakeupTime,
//                                                            changeWakeupTime: timeMission.changeWakeupTime)))
//        }
//    }
// }
