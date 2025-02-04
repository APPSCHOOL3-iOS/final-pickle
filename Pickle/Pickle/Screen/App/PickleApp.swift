//
//  PickleApp.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    @EnvironmentObject var missionStore: MissionStore
    @EnvironmentObject var notificationManager: NotificationManager
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        PickleApp.setUpDependency()
        _ = RealmMigrator()
        return true
    }
}

struct PickleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var todoStore = TodoStore()
    @StateObject private var missionStore = MissionStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var pizzaStore = PizzaStore()
    @StateObject private var healthKitStore: HealthKitStore = HealthKitStore()
    @StateObject private var navigationStore = NavigationStore(mediator: NotiMediator.shared)
    @StateObject private var notificationManager = NotificationManager(mediator: NotiMediator.shared)
    @StateObject private var timerVM = TimerViewModel()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var debugDelete: Bool = true
    @AppStorage(STORAGE.backgroundNumber.id) var backgroundNumber: Int = 0
    @AppStorage(STORAGE.isRunTimer.id) var isRunTimer: Bool = false
    @AppStorage(STORAGE.todoId.id) var todoId: String = ""
    
    init() {
        Thread.sleep(forTimeInterval: 1)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {  debugDelete.toggle() }    // 내부의 contentView onApper 보다 늦게 실행됨 Debug Delete
                .environmentObject(todoStore)
                .environmentObject(missionStore)
                .environmentObject(userStore)
                .environmentObject(notificationManager)
                .environmentObject(pizzaStore)
                .environmentObject(timerVM)
                .environmentObject(healthKitStore)
                .environmentObject(navigationStore)
                .onChange(of: scenePhase) { newScene in
                    backgroundEvent(newScene: newScene)
                }
        }
    }
    
    private func backgroundEvent(newScene: ScenePhase) {
        if newScene == .background {
            backgroundNumber += 1
            
            timerVM.activeNumber += 1
            
            if isRunTimer {
                timerVM.isPuase = true
                timerVM.backgroundTimeStemp = Date()
                timerVM.fromBackground = true
                timerVM.backgroundTimeRemain = timerVM.timeRemaining
                timerVM.backgroundSpendTime = timerVM.spendTime
                timerVM.backgroundTimeExtra = timerVM.timeExtra
            }
        }
        
        if newScene == .active {
            Log.debug("ACTIVE")
            Log.debug("activeNumber: \(timerVM.activeNumber)")
            Log.debug("backgroundNumber: \(backgroundNumber)")
            Log.debug("isRunTimer: \(isRunTimer)")
            
            if isRunTimer {
                if timerVM.activeNumber != backgroundNumber {
                    timerVM.todo = todoStore.getSeletedTodo(id: todoId)
                    timerVM.showOngoingAlert = true
                }
                
                if timerVM.fromBackground {
                    timerVM.makeRandomSaying()
                    let currentTime: Date = Date()
                    var diff = currentTime.timeIntervalSince(timerVM.backgroundTimeStemp)
                    timerVM.timeRemaining = timerVM.backgroundTimeRemain
                    timerVM.spendTime = timerVM.backgroundSpendTime
                    timerVM.spendTime += diff
                    timerVM.timeExtra = timerVM.backgroundTimeExtra
                    
                    if timerVM.timeRemaining > 0 {
                        if timerVM.timeRemaining > diff {
                            timerVM.timeRemaining -= diff
                        } else {
                            diff -= timerVM.timeRemaining
                            timerVM.isDecresing = false
                            timerVM.timeExtra += diff
                        }
                    } else {
                        timerVM.timeExtra += diff
                    }
                    
                    timerVM.fromBackground = false
                    timerVM.isPuase = false
                    
                }
            }
        }
    }
}

extension PickleApp {
    /// 테스트용
    func dummyDelete() {
        userStore.deleteuserAll()
        missionStore.deleteAll(mission: .time(.init()))
        missionStore.deleteAll(mission: .behavior(.init()))
        pizzaStore.deleteAll()
    }
    
    static func setUpDependency() {
        //        DependencyContainer.register(DBStoreKey.self, RealmStore.previews)
        Container.register(DBStoreKey.self, RealmStore())
        Container.register(TodoRepoKey.self, TodoRepository())
        Container.register(BehaviorRepoKey.self, BehaviorMissionRepository())
        Container.register(TimeRepoKey.self, TimeMissionRepository())
        Container.register(UserRepoKey.self, UserRepository())
        Container.register(PizzaRepoKey.self, PizzaRepository())
    }
}
