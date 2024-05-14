//
//  HomeView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct HomeView: View {
    typealias PizzaSelection = PizzaSelectedView.Selection
    typealias TodoSelection = UpdateTodoView.Selection
    typealias TimerSelection = TodoCellView.Selection
    
    init() {
        navigationAppearenceSetting()
    }
    
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var navigationStore: NavigationStore
    @EnvironmentObject var timerVM: TimerViewModel
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    
    @Environment(\.scrollEnable) var scrollEnable
    
    @State private var tabBarvisibility: Visibility = .visible
    @State private var showCompleteAlert: Bool = false
    
    @State private var pizzaSelection: PizzaSelection = .init()
    @State private var editSelection: TodoSelection = .init()
    @State private var timerSelection: TimerSelection = .init()
    @State private var description: String = ""
    
    @State private var ongoingTodo: Todo = Todo.onGoing
    @AppStorage(STORAGE.isRunTimer.id, store: .group) var isRunTimer: Bool = false
    @AppStorage(STORAGE.todoId.id, store: .group) var todoId: String = ""
    
    var body: some View {
        content
            .task {
                await todoStore.fetch()  // MARK: Persistent 저장소에서 Todo 데이터 가져오기
                if isRunTimer { ongoingTodo = todoStore.getSeletedTodo(id: todoId) }
            }
            .onReceive(userStore.$user) {
                userUpdateAction(user: $0)
            }
            .onReceive(userStore.$currentPizza) { currentPizza in
                currentPizzaUpdateAction(currentPizza: currentPizza)
            }
            .onReceive(navigationStore.$homeSheet) { sheet in
                routing(route: sheet)
            }
            .onReceive(viewModel.$pizzaPosition) { _ in
                viewModel.trigger(action: .updatePosition(userStore.user))
            }
            .onChange(of: pizzaSelection.seletedPizza) { pizza in
                if pizza.lock == false { userStore.trigger(action: .select(pizza)) }
            }
            .navigationDestination(for: HomeView.Routing.self) { route in
                routing(stack: route)
            }
    }
    
    private func userUpdateAction(user: User) {
        pizzaSelection.pizzas = user.currentPizzas.compactMap { $0.pizza }
    }
    
    private func currentPizzaUpdateAction(currentPizza: CurrentPizza) {
        if let pizza = currentPizza.pizza {
            withAnimation(.easeIn(duration: 0.1)) {
                self.pizzaSelection.currentPizza = pizza
                self.viewModel.trigger(action: .updateCurrent(currentPizza))
            }
        }
        
        if currentPizza.currentPizzaSlice >= 8 {
            navigationStore.pushHomeView(home: .showCompleteAlert(true))
        }
    }
    
    private func stopTodo() {
        var todo = Todo(todo: timerVM.todo)
        todo.spendTime = 0
        todo.status = .giveUp
        todoStore.update(todo: todo)
        isRunTimer = false
    }
    
    private func unLockPizzaAction() {
       let effect = viewModel.trigger(action: .unlock(userStore, pizzaSelection.seletedPizza))
        if case let .unlockFail(count) = effect {
            description = "피자 \(count)판을 더 모아야 잠금을 해제할 수 있어요"
            return
        }
        if case .success = effect {
            pizzaSelection.isPizzaPuchasePresent = false
            return
        }
   }
}

// MARK: HomeView Component , PizzaView, button, temp component, task complte label
extension HomeView {
    
    private var completeMessage: CompleteMessage {
        .init(isPresented: $showCompleteAlert,
              pizzaName: userStore.currentPizza.pizza?.image ?? "",
              title: "축하합니다",
              contents: userStore.currentPizza.pizza?.name ?? "",
              action: {
            userStore.addPizzaCount()
            navigationStore.dismiss(home: .showCompleteAlert(false))
        })
    }
    
    private var stopAlertContent: AlertContent {
        .init(isPresented: $timerVM.showOngoingAlert,
              title: "타이머 중단",
              alertContent: "앱이 종료되어 피자굽기를 실패하였습니다",
              primaryButtonTitle: "확인",
              secondaryButtonTitle: "",
              primaryAction: stopTodo,
              externalTapAction: stopTodo)
    }
    
    var content: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    EmptyView()
                        .id(ScrollAnchor.home)
                    
                    PizzaPagingView(routing: navigationStore.pushHomeView(home: .isPizzaSeleted(true)))
                        .frame(width: CGFloat.screenWidth,
                               height: CGFloat.screenWidth / 2 + 44,
                               alignment: .center)
                    
                    PizzaSliceDescriptionView() /* 피자 슬라이스 텍스트 뷰 + description View */
                        
                    if todoStore.readyTodos.isEmpty {
                        TodoEmptyView()
                    } else {
                        // MARK: .ready 필터시 포기, 완료하면 시트 슈루룩 사라져버림
                        ForEach(todoStore.readyTodos, id: \.id) { todo in
                            TodoCellView(todo: todo)
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                                .onTapGesture {
                                    navigationStore.pushHomeView(home: .isShowingEditTodo(true, todo))
                                }
                        }          // 할일 목록 테이블 뷰
                    }
                }
                .environmentObject(viewModel)
                .padding(.vertical, 20)
            }
            .onChange(of: scrollEnable.root.wrappedValue) { enable in
                if enable { withAnimation { proxy.scrollTo(ScrollAnchor.home) } }
            }
            
        }
        .navigationSetting(tabBarvisibility: $tabBarvisibility) /* 뷰 네비게이션 셋팅 custom modifier */
                                                                /* leading - (MissionView), trailing - (RegisterView) */
        .completePizzaAlert(message: completeMessage) 
        
        .sheetModifier(selection: $pizzaSelection)              /* PizzaSelectedView 피자 뷰를 클릭했을시 실행되는 Modifier */
        
        .fullScreenCover(edit: $editSelection)                  /* 풀스크린 Todo 수정뷰 모달 */
        
        .fullScreenCover(timer: $timerSelection)                /* 풀스크린  Timer 뷰  모달 */
        
        .stopAlert(content: stopAlertContent)                   /* 할일 타이머 실패시 띄울 Alert */
        
        .showPizzaPurchaseAlert($pizzaSelection, $description, unLockPizzaAction) /* 피자 선택 sheet에서 피자를 선택하면 실행되는 alert Modifier */
    }
}

// MARK: Home View Routing
extension HomeView {
    private func routing(stack route: HomeView.Routing) -> some View {
        if route == .pushMission {
            return AnyView(
                MissionView()
                .backKeyModifier(tabBarvisibility: $tabBarvisibility)
            )
        }
        
        if route == .pushRegisterTodo {
            return AnyView(
                RegisterView(willUpdateTodo: .constant(Todo.sample),
                             successDelete: .constant(false),
                             isModify: false)
                .backKeyModifier(tabBarvisibility: $tabBarvisibility)
            )
        }
        return AnyView(EmptyView())
    }
    
    private func routing(route: HomeView.Routing) {
        switch route {
        case .isPizzaSeleted(let flag):
            withAnimation {
                pizzaSelection.isPizzaSelected = flag
            }
        case .isShowingEditTodo(let flag, let todo):
            self.editSelection = TodoSelection.init(isShowing: flag, seleted: todo)
        
        case .showCompleteAlert(let flag):
            withAnimation {
                self.showCompleteAlert = flag
            }
        case .isShowingTimerView(let todo):
            self.timerSelection = .init(selectedTodo: todo,
                                        isShowingTimer: !timerSelection.isShowingTimer)
        default:
            break
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static let todo = TodoStore()
    static let pizza = PizzaStore()
    static let user = UserStore()
    static let mission = MissionStore()
    
    static var previews: some View {
        NavigationStack {
#if DEBUG
            HomeView()
                .environmentObject(TimerViewModel())
                .environmentObject(todo)
                .environmentObject(pizza)
                .environmentObject(user)
                .environmentObject(mission)
                .environmentObject(NavigationStore(mediator: NotiMediator()))
                .environmentObject(NotificationManager(mediator: NotiMediator()))
                .environment(\.scrollEnable, .constant(.init()))
#else
            Text("value")
#endif
        }.onAppear {
            PreviewsContainer.setUpDependency()
            PreviewsContainer.dependencySetting(pizza: pizza, user: user, todo: todo, mission: mission)
        }
    }
}
