//
//  ContentView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI
import PickleCommon

struct ContentView: View {
    @AppStorage(STORAGE.onboarding.id, store: .group) var isOnboardingViewActive: Bool = true
    @AppStorage(STORAGE.systemTheme.id, store: .group) private var systemTheme: Int = SchemeType.allCases.first!.rawValue
    
    @EnvironmentObject var pizzaStore: PizzaStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var missionStore: MissionStore
    @EnvironmentObject var healthKitStore: HealthKitStore
    @EnvironmentObject var navigationStore: NavigationStore
    
    @State private var rootScrollEnable: Bool = false
    @State private var rootScrollEnableKey = ScrollEnableKey(root: false, calendar: false)
    
    var selectedScheme: ColorScheme? {
        guard let theme = SchemeType(rawValue: systemTheme) else { return nil }
        switch theme {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return nil
        }
    }
    
    var body: some View {
        TabView(selection: navigationStore.createTabViewBinding(key: $rootScrollEnableKey)) {
            NavigationStack(path: $navigationStore.homeNav) {
                HomeView()
            }.tabItem {
                Label("홈", systemImage: "house")
                    .environment(\.symbolVariants, .fill)
            }.tag(TabItem.home)
            
            NavigationStack(path: $navigationStore.calendarNav) {
                CalendarView()
            }.tabItem {
                Label("달력", systemImage: "calendar")
                    .environment(\.symbolVariants, .fill)
            }.tag(TabItem.calendar)
            
            NavigationStack {
                PizzaSummaryView()
            }.tabItem {
                Label("통계", systemImage: "list.clipboard.fill")
                    .environment(\.symbolVariants, .fill)
            }.tag(TabItem.statistics)
            
            NavigationStack(path: $navigationStore.settingNav) {
                SettingView()
            }
            .tabItem {
                Label("설정", systemImage: "gearshape")
                    .environment(\.symbolVariants, .fill)
            }.tag(TabItem.setting)
        }
        .onAppear {
            initUserSetting()
        }
        .fullScreenCover(isPresented: $isOnboardingViewActive) {
            SettingNotiicationView(isShowingOnboarding: $isOnboardingViewActive)
        }
        .tint(.pickle)
        .preferredColorScheme(selectedScheme)
        .scrollEnableInject($rootScrollEnableKey)
    }
}

extension ContentView {
    
    private func initUserSetting() {
        self.userSetting()
        missionStore.missionSetting()
    }
    
    private func userSetting() {
        do {
            try userStore.fetchUser()
        } catch {
            // MARK: Add User Action
            errorHandler(error)
        }
    }
    
    private func errorHandler(_ error: Error) {
        guard let error = error as? PersistentedError else { return }
        if error == .fetchUserError {
            var user = User.defaultUser
            
            user.currentPizzas = Pizza.allCasePizza.map { CurrentPizza(pizza: $0)}
            user.pizzaID = user.currentPizzas.first!.pizza!.id
            
            userStore.addUser(default: user)
            try! userStore.fetchUser()
        } else if error == .addFaild {
            Log.error("피자를 추가하는 중에 에러 발생")
        } else if error == .fetchError {
            Log.error("페치를 하는 중에 에러 발생")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitStore())
        .environmentObject(MissionStore())
        .environmentObject(NavigationStore(mediator: NotiMediator()))
        .environmentObject(UserStore())
        .environmentObject(PizzaStore())
}
