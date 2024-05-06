//
//  NavigationStore.swift
//  Pickle
//
//  Created by 박형환 on 10/29/23.
//

import SwiftUI

@MainActor
final class NavigationStore: ObservableObject, NotificationService {
    
    let mediator: Mediator
    
    @Published var selectedTab: TabItem = .home
    @Published var homeNav: [HomeView.Routing] = []
    @Published var homeSheet: HomeView.Routing = .none
    @Published var calendarNav: [CalendarView.Routing] = []
    @Published var settingNav: [SettingView.Routing] = []
    
    init(mediator: Mediator) {
        self.mediator = mediator
        self.mediator.navigation = self
    }
    
    func receive(notification type: NotiType) async {
        if case let .todo(info) = type {
            pushHomeView(home: .isShowingTimerView(info))
        }
        if case .health = type {
            pushHomeView(home: .pushMission)
        }
    }
    
    func post(notification type: NotiType) async {
        fatalError("do not call this method")
    }

    func pushHomeView(home routing: HomeView.Routing) {
        switch routing {
        case .pushMission, .pushRegisterTodo:
            homeNav.append(routing)
        case    .isShowingEditTodo,
                .isPizzaSeleted,
                .showCompleteAlert,
                .isShowingTimerView:
            homeSheet = routing
        case .none:
            break
        }
    }
    
    func dismiss(home routing: HomeView.Routing) {
        switch routing {
        case .pushMission, .pushRegisterTodo:
            homeNav.removeLast()
        case    .isShowingEditTodo,
                .isPizzaSeleted,
                .showCompleteAlert,
                .isShowingTimerView:
            homeSheet = routing
        case .none:
            break
        }
    }
    
    func createTabViewBinding(key enable: Binding<ScrollEnableKey>) -> Binding<TabItem> {
        Binding<TabItem>(
            get: { [weak self] in
                guard let self else { return .home }
                return self.selectedTab
            },
            set: { [weak self] _seletedTab in
                guard let self else { return }
                if _seletedTab == self.selectedTab {
                    switch _seletedTab {
                    case .home:
                        stopScrollAnimaionAndEnable(scroll: enable.root)
                    case .calendar:
                        stopScrollAnimaionAndEnable(scroll: enable.calendar)
                    case .setting:
                        stopScrollAnimaionAndEnable(scroll: enable.root)
                    default:
                        break
                    }
                }
                selectedTab = _seletedTab
            }
        )
    }
    
    private func stopScrollAnimaionAndEnable(scroll: Binding<Bool>) {
        scroll.wrappedValue.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            scroll.wrappedValue.toggle()
        }
    }
}

// MARK: Test Function
extension NavigationStore {
#if DEBUG
    func navigationTest() {
        Task {
            try await Task.sleep(seconds: 1)
            await testNavigation(first: self.pushHomeView(home: .pushMission),
                                 second: self.dismiss(home: .pushMission))
            
            await testNavigation(first: self.pushHomeView(home: .pushRegisterTodo),
                                 second: self.dismiss(home: .pushRegisterTodo))
            
            await testNavigation(first: self.pushHomeView(home: .isShowingEditTodo(true, Todo.sample)),
                                 second: self.dismiss(home: .isShowingEditTodo(false, Todo.sample)))
            
            await testNavigation(first: self.pushHomeView(home: .isPizzaSeleted(true)),
                                 second: self.dismiss(home: .isPizzaSeleted(false)))
        }
    }
    #endif
    
    #if DEBUG
    func testNavigation(first action: @autoclosure @escaping () -> Void,
                        second action2: @autoclosure @escaping () -> Void) async {
        do {
            try await Task.sleep(seconds: 1)
            action()
            Log.debug("first action trigger : \(String(describing: action.self))")
            try await Task.sleep(seconds: 1)
            action2()
            Log.debug("second action trigger : \(String(describing: action2.self))")
        } catch {
            Log.error(error)
        }
    }
    #endif
}
