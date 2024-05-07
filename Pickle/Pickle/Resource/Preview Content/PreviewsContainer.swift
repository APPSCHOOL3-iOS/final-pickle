//
//  PreviewsContainer.swift
//  Pickle
//
//  Created by 박형환 on 10/19/23.
//

import Foundation

enum PreviewsContainer {
    static func setUpDependency() {
        Container.register(DBStoreKey.self, RealmStore.previews)
        Container.register(TodoRepoKey.self, TodoRepository())
        Container.register(BehaviorRepoKey.self, BehaviorMissionRepository())
        Container.register(TimeRepoKey.self, TimeMissionRepository())
        Container.register(UserRepoKey.self, UserRepository())
        Container.register(PizzaRepoKey.self, PizzaRepository())
    }
    
    @MainActor 
    static func dependencySetting(pizza: PizzaStore? = nil,
                                  user: UserStore? = nil,
                                  todo: TodoStore? = nil,
                                  mission: MissionStore? = nil) {
        
        if let pizza { Task { await pizzaSetting(pizza) } }
        if let user { userSetting(user) }
        if let mission { missionSetting(mission) }
    }
    
    /// 처음 한번만 실행되는 함수,
    /// 피자를 셋팅하여 아직 열리지 않은 피자는 lock 을 true 로 한다.
    @MainActor static func pizzaSetting(_ store: PizzaStore) async {
        let value = await store.fetch()
        if !value.isEmpty { return }
        Pizza.allCasePizza.forEach { pizza in
            do {
                try store.add(pizza: pizza)
            } catch {
                errorHandler(error, nil)
            }
        }
    }
    
    @MainActor static func userSetting(_ store: UserStore) {
        do {
            try store.fetchUser()
        } catch {
            errorHandler(error, store)
        }
    }
    
    // 마이그래이션
    // 코어데이터할때도 마이그레이션 어쩌고 데이터변경이 일어나면 ~
    // 배ㅠ포할땐 마이그레이션어쩌고 코드도 넣어서 ? 지금은 그냥 앱삭제 다시깔기
    // 버전이 바뀌면 파일 바뀌니까 그거에 대응해줘야함
    @MainActor static func missionSetting(_ store: MissionStore) {
        let (t, b) = store.fetch()
        if !t.isEmpty && !b.isEmpty { return }
        if t.isEmpty {
            let time = TimeMission(title: "기상 미션", status: .done, date: Date(), wakeupTime: Date())
            store.add(mission: .time(time))
        }
        if b.isEmpty {
            let behavior = BehaviorMission(id: "걷기 미션",
                                           title: "value",
                                           status: .ready,
                                           status1: .ready,
                                           status2: .ready)
            store.add(mission: .behavior(behavior))
        }
    }
    
    @MainActor private static func errorHandler(_ error: Error, _ store: UserStore?) {
        guard let error = error as? PersistentedError else { return }
        if error == .fetchUserError {
            store?.addUser()
            try! store?.fetchUser()
        } else if error == .addFaild {
            Log.error("피자를 추가하는 중에 에러 발생")
        } else if error == .fetchError {
            Log.error("페치를 하는 중에 에러 발생")
        }
    }
}
