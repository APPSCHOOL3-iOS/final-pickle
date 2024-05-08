//
//  MissionView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct MissionView: View {
    @EnvironmentObject var missionStore: MissionStore
    @EnvironmentObject var healthKitStore: HealthKitStore
    
    @AppStorage(STORAGE.is24HourClock.id) var is24HourClock: Bool = true
    @AppStorage(STORAGE.timeFormat.id) var timeFormat: String = "HH:mm"
    
    @State private var showsAlert: Bool = false
    @State private var showSuccessAlert: Bool = false
    @State private var behaviorMissions: [BehaviorMission] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(behaviorMissions.indices, id: \.self) { index in
                    if behaviorMissions[safe: index] != nil {
                        BehaviorMissionStyleView(behaviorMission: $behaviorMissions[index], showsAlert: $showsAlert, healthKitStore: healthKitStore)
                    }
                }
                
                Text("'설정 > 건강 > 데이터 접근 및 기기'에서 권한을 수정할 수 있습니다.")
                    .font(.nanumLt)
                    .foregroundStyle(.secondary)
                    .lineSpacing(5)
                    .padding(.top, 1)
                
                Spacer()
            }
        }
        .onAppear {
            timeFormat = is24HourClock ? "HH:mm" : "a h:mm"
            
            healthKitStore.requestAuthorization { success in
                if success { healthKitStore.fetchStepCount() }
            }
            healthKitStore.fetchStepCount()
            missionFetch()
        }

        .refreshable {
            healthKitStore.fetchStepCount()
            missionFetch()
        }
        .navigationTitle("미션")
        .navigationBarTitleDisplayMode(.inline)
        .getRewardAlert(
            isPresented: $showsAlert,
            title: "미션 성공",
            point: 1,
            primaryButtonTitle: "확인",
            primaryAction: {}
        )
    }
    
    func missionFetch() {
        missionStore.missionSetting()
        let temp = missionStore.behaviorMissions.filter { $0.date.isToday}
        behaviorMissions = temp
    }
}

struct MissionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MissionView()
                .environmentObject(MissionStore())
        }
    }
}
