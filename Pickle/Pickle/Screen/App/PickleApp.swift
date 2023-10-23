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
        let _ = RealmMigrator()
        
        // App Refresh Task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.ddudios.realpizza.refresh_badge", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        // Processing Task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.ddudios.realpizza.refresh_process", using: nil) { task in
            self.handleProcessingTask(task: task as! BGProcessingTask) // 타입 캐스팅 유의 (BG'Processing'Task)
        }
        
        return true
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        // 다음 동작 수행, 반복시 필요
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // 가벼운 백그라운드 작업 작성
        task.setTaskCompleted(success: false)
    }
    
    func handleProcessingTask(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // 무거운 백그라운드 작업 작성
        task.setTaskCompleted(success: true)
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.ddudios.realpizza.refresh_badge")
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
        } catch {
            print("\(Date()): Could not schedule app refresh: \(error)")
        }
    }
    
    func scheduleProcessingTaskIfNeeded() {
        
        let request = BGProcessingTaskRequest(identifier: "com.ddudios.realpizza.refresh_process")
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("\(Date()): Could not schedule processing task: \(error)")
        }
        //        let oneday = TimeInterval(24 * 60 * 60)
        
        guard missionStore.timeMissions[0].date.format("yyyy-MM-dd") != Date().format("yyyy-MM-dd") else { return }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.ddudios.realpizza.refresh_process", using: nil) { task in
            self.handleProcessingTask(task: task as! BGProcessingTask)
            self.updateRealmDataTomorrow()
        }
    }
    
    func updateRealmDataTomorrow() {
        let dateComponent = Calendar.current.dateComponents([.hour, .minute], from: missionStore.timeMissions[0].changeWakeupTime)
        
        notificationManager.scheduleNotification(
            localNotification: LocalNotification(identifier: UUID().uuidString,
                                                 title: "기상 미션 알림",
                                                 body: "기상 미션을 완료하고 피자조각을 획득하세요.",
                                                 dateComponents: dateComponent,
                                                 repeats: false,
                                                 type: .calendar)
        )
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        
        sceneConfiguration.delegateClass = MySceneDelegate.self
        
        return sceneConfiguration
    }
}

@main
struct PickleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var todoStore = TodoStore()
    @StateObject private var missionStore = MissionStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var pizzaStore = PizzaStore()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var timerVM = TimerViewModel()
    @Environment(\.scenePhase) var scenePhase
    @State private var debugDelete: Bool = true
    
    // Launch Screen Delay
    init() {
        Thread.sleep(forTimeInterval: 2)
    }
    
    var body: some Scene {
        WindowGroup {
            if debugDelete {
                let _ = UserDefaults.standard.set(false, forKey: "__UIConstraintBasedLayoutLogUnsatisfiable")
                let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
                //                let _ = dummyDelete()
            }
            
            ContentView()
                .onAppear { Log.error("contentVIew onAppear"); debugDelete.toggle() }    // 내부의 contentView onApper 보다 늦게 실행됨 Debug Delete
                .environmentObject(todoStore)
                .environmentObject(missionStore)
                .environmentObject(userStore)
                .environmentObject(notificationManager)
                .environmentObject(pizzaStore)
                .environmentObject(timerVM)
                .onChange(of: scenePhase) { newScene in
                    backgroundEvent(newScene: newScene)
                }
        }
    }
    
    private func backgroundEvent(newScene: ScenePhase) {
        if newScene == .background {
            print("BACKGROUD")
            
            timerVM.backgroundTimeStemp = Date()
            print("backgroundTimeStemp: \(timerVM.backgroundTimeStemp)")
            timerVM.fromBackground = true
        }
        if newScene == .active {
            print("ACTIVE")
            
            if timerVM.fromBackground {
                timerVM.makeRandomSaying()
                print("\(timerVM.wiseSaying)")
                
                print("backgroundTimeStemp: \(timerVM.backgroundTimeStemp)")
                
                var currentTime: Date = Date()
                print("currentTime:\(currentTime) / Date(): \(Date())")
                
                var diff = currentTime.timeIntervalSince(timerVM.backgroundTimeStemp)
                print("diff: \(TimeInterval(diff))")
                
                print("timeRemaining: \(timerVM.timeRemaining)")
                
                timerVM.spendTime += diff
                
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
            }
        }
    }
}

extension PickleApp {
    /// 테스트용
    func dummyDelete() {
        Log.debug("dummy Delete called")
        userStore.deleteuserAll()
        missionStore.deleteAll(mission: .time(.init()))
        missionStore.deleteAll(mission: .behavior(.init()))
        pizzaStore.deleteAll()
        Log.debug("dummy Delete end")
    }
    
    static func setUpDependency() {
        //        DependencyContainer.register(DBStoreKey.self, RealmStore.previews)
        DependencyContainer.register(DBStoreKey.self, RealmStore())
        DependencyContainer.register(TodoRepoKey.self, TodoRepository())
        DependencyContainer.register(BehaviorRepoKey.self, BehaviorMissionRepository())
        DependencyContainer.register(TimeRepoKey.self, TimeMissionRepository())
        DependencyContainer.register(UserRepoKey.self, UserRepository())
        DependencyContainer.register(PizzaRepoKey.self, PizzaRepository())
    }
}
