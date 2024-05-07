//
//  HomeView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct HomeView: View {
    
    init() { navigationAppearenceSetting() }
    
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var pizzaStore: PizzaStore
    @EnvironmentObject var timerVM: TimerViewModel
    
    @State private var goalProgress: Double = 0.0
    @State private var animatedText = ""
    
    @State private var currentIndex = 0
    let fullText = "할일을 완료하고 피자를 모아보아요"
    
    @State private var tabBarvisibility: Visibility = .visible
    @State private var isShowingEditTodo: Bool = false
    @State private var isPizzaSeleted: Bool = false
    @State private var isPizzaPuchasePresented: Bool = false
    @State private var showCompleteAlert: Bool = false
    
    @State private var placeHolderContent: String = "?" // MARK: Dot Circle 뷰의 원 중심에 있는 content
    @State private var seletedTodo: Todo = Todo.sample
    @State private var seletedPizza: Pizza = Pizza.defaultPizza
    
    typealias PizzaImage = String
    @State private var currentPizzaImg: PizzaImage = "margherita"
    @State private var currentPizza: Pizza = .defaultPizza
    @State private var updateSignal: Bool = false       // Pizza Image Update Signal
    
    private let goalTotal: Double = 8                   // 피자 완성 카운트
    
    private var taskPercentage: Double {
        Double(userStore.user.currentPizzaSlice) / goalTotal
    }
    
    /// Pizza  ex) 1 / 8 - 유저의 완료한 피자조각 갯수....
    private var pizzaTaskSlice: String {
        "\(Int(userStore.user.currentPizzaSlice)) / \(Int(goalTotal))"
    }
    
    var body: some View {
        ScrollView {
            VStack {
                makePizzaView(pizza: currentPizza)                 /* 피자 뷰 */
                pizzaSliceAndDescriptionView    /* 피자 슬라이스 텍스트 뷰 + description View */
                
                if todoStore.readyTodos.isEmpty {
                    VStack(spacing: 16) {
                        Image("picklePizza")
                            .resizable()
                            .scaledToFit()
                            .frame(width: .screenWidth - 200)
                        
                        Text("오늘 할일을 추가해 주세요!")
                            .frame(maxWidth: .infinity)
                            .font(.pizzaRegularSmallTitle)
                    }
                    .padding(.bottom)
                } else {
                    todosTaskTableView          // 할일 목록 테이블 뷰
                }
            }.padding(.vertical, 20)
        }
        .navigationSetting(tabBarvisibility: $tabBarvisibility) /* 뷰 네비게이션 셋팅 custom modifier */
                                                                  /* leading - (MissionView), trailing - (RegisterView) */
        
        .fullScreenCover(isPresented: $isShowingEditTodo,         /* fullScreen cover */
                         seletedTodo: $seletedTodo)               /* $isShowingEditTodo - 당연히 시트 띄우는 binding값 */
                                                                  /* $seletedTodo - todosTaskTableView 에서 선택된 Todo 값 */
        
        .sheetModifier(isPresented: $isPizzaSeleted,               /* PizzaSelectedView 피자 뷰를 클릭했을시 실행되는 Modifier */
                       isPurchase: $isPizzaPuchasePresented,
                       seletedPizza: $seletedPizza,
                       currentPizza: $currentPizza,
                       updateSignal: $updateSignal)
        
        .showPizzaPurchaseAlert(seletedPizza,                   /* 피자 선택 sheet에서 피자를 선택하면 실행되는 alert Modifier */
                                $isPizzaPuchasePresented) {     /* 두가지의 (액션)클로져를 받는다, */
            Log.debug("인앱 결제 액션")                             /* 1. 구매 액션 */
            // MARK: 잠금해제 액션 부터 해보자
            userStore.unLockPizza(pizza: seletedPizza)
            updateSignal.toggle()
        } navAction: {                                          /* 2. 피자 완성하러 가기 액션 */
            Log.debug("피자 완성하러 가기 액션")
            currentPizzaImg = seletedPizza.image    // MARK: Seleted Pizza 를 완성하러 가기 클릭하면 이미지 변신
                                                    // MARK: 완성하러 가기 액션은 변경을 시켜야 하나? 일단 해봐 ->
                                                    // MARK: Navigation To 완성액션으로

        }
        .onAppear { /* */
            updateSignal.toggle()
            placeHolderContent = userStore.user.currentPizzaSlice > 0 ? "" : "?"  // placeHolder 표시할지 말지 분기처리
        }
        .task { await todoStore.fetch() }                       // MARK: Persistent 저장소에서 Todo 데이터 가져오기
        .onChange(of: userStore.user.currentPizzaSlice,         // MARK: 현재 피자조각 의 개수가 변할때 마다 호출되는 modifier
                  perform: { slice in
            placeHolderContent = slice == 0 ? "?" : ""          // 0일때는 place Holder content, 조각이 한개라도 존재하면 빈문자열
            
            if slice % 8 == 0 {
                showCompleteAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.showCompleteAlert = false
                }
            }
        })
        .completePizzaAlert(isPresented: $showCompleteAlert, pizzaName: seletedPizza.image, title: "축하합니다", contents: seletedPizza.name)
        
        .onChange(of: seletedPizza,
                  perform: { pizza in
            if pizza.lock { 
                isPizzaPuchasePresented.toggle()
            } else { /*currentPizzaImg = pizza.image*/
                currentPizza = pizza
            }
        })
        .alert(isPresented: $timerVM.showingOngoingAlert) {
            Alert(title: Text("타이머아직안끝남.."))
        }
    }
}

// MARK: HomeView Component , PizzaView, button, temp component, task complte label
extension HomeView {
    func makePizzaView(pizza: Pizza) -> some View {
        PizzaView(taskPercentage: taskPercentage, currentPizza: pizza, content: $placeHolderContent)
            .frame(width: CGFloat.screenWidth / 2,
                   height: CGFloat.screenWidth / 2)
            .padding()
            .onTapGesture {
                withAnimation {
                    isPizzaSeleted.toggle()
                }
            }
    }
    
    var pizzaSliceAndDescriptionView: some View {
        VStack(spacing: 0) {
            // tempButton
            Text("\(pizzaTaskSlice)")
                .font(.chab)
                .foregroundStyle(Color.pickle)
            
            Text(animatedText)
                .font(.pizzaHeadline)
                .onAppear {
                    currentIndex = 0
                    animatedText = ""
                    startTyping()
                }
                .padding(.vertical, 8)
                .padding(.bottom, 20)
        }
        .padding(.horizontal)
    }
    
    var todosTaskTableView: some View {
        // MARK: .ready 필터시 포기, 완료하면 시트 슈루룩 사라져버림
        ForEach(todoStore.readyTodos, id: \.id) { todo in
            TodoCellView(todo: todo)
                .padding(.horizontal)
                .padding(.vertical, 2)
                .onTapGesture {
                    seletedTodo = todo
                    isShowingEditTodo.toggle()
                }
        }
    }
    
    private var tempButton: some View {
        // MARK: 테스트용, 추후 삭제
        Button("할일 완료") {
            withAnimation {
                do {
                    try userStore.addPizzaSlice(slice: 1)
                } catch {
                    Log.error("❌피자 조각 추가 실패❌")
                }
            }
        }
        .foregroundStyle(.secondary)
    }
}

// MARK: HomeView Modifier
extension View {
    func navigationSetting(tabBarvisibility: Binding<Visibility>) -> some View {
        modifier(NavigationModifier(tabBarvisibility: tabBarvisibility))
    }
    
    func sheetModifier(isPresented: Binding<Bool>,
                       isPurchase: Binding<Bool>,
                       seletedPizza: Binding<Pizza>,
                       currentPizza: Binding<Pizza>,
                       updateSignal: Binding<Bool>) -> some View {
        
        modifier(HomeView.SheetModifier(isPresented: isPresented,
                                         isPizzaPuchasePresented: isPurchase,
                                        seletedPizza: seletedPizza,
                                        currentPizza: currentPizza,
                                       updateSignal: updateSignal))
    }
    
    func fullScreenCover(isPresented: Binding<Bool>,
                         seletedTodo item: Binding<Todo>) -> some View {
        
        modifier(HomeView.FullScreenCoverModifier(isPresented: isPresented,
                                                  seletedTodo: item))
    }
    
    func showPizzaPurchaseAlert(_ pizza: Pizza,
                                _ isPizzaPuchasePresented: Binding<Bool>,
                                _ purchaseAction: @escaping () -> Void,
                                navAction: @escaping () -> Void) -> some View {
        modifier(PizzaAlertModifier(isPresented: isPizzaPuchasePresented,
                                    title: "\(pizza.name)",
                                    price: "",
                                    descripation: "피자 2판을 완성하면 얻을수 있어요",
                                    image: "\(pizza.image)",
                                    lock: pizza.lock,
                                    puchaseButtonTitle: "피자 구매하기 (₩1,200)",
                                    primaryButtonTitle: "피자 완성하러 가기",
                                    primaryAction: purchaseAction,
                                    pizzaMakeNavAction: navAction))
    }
}

extension HomeView {
    
    struct SheetModifier: ViewModifier {
        @Binding var isPresented: Bool
         @Binding var isPizzaPuchasePresented: Bool
        
        @State private var pizzas: [Pizza] = []
        @Binding var seletedPizza: Pizza
        @Binding var currentPizza: Pizza
        @Binding var updateSignal: Bool
        
        @GestureState private var offset = CGSize.zero
        @EnvironmentObject var pizzaStore: PizzaStore
        @EnvironmentObject var userStore: UserStore
        
        func fetchPizza() async {
            pizzas = await pizzaStore.fetch()
            Log.debug("pizzas: \(pizzas.map(\.lock))")
        }
        
        func body(content: Content) -> some View {
            
            content
                .overlay {
                    if isPresented {
                        // For getting frame for image
                        GeometryReader { proxy in
                            let frame = proxy.frame(in: .global)
                            Color.black
                                .opacity(0.3)
                                .frame(width: frame.width, height: frame.height)
                        }
                        .ignoresSafeArea()
                        
                        CustomSheetView(isPresented: $isPresented) {
                            PizzaSelectedView(pizzas: $pizzas,
                                              seletedPizza: $seletedPizza,
                                              currentPizza: $currentPizza,
                                              isPizzaPuchasePresented: $isPizzaPuchasePresented)
                        }.transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .onChange(of: offset, perform: { offset in
                    Log.debug("offset: \(offset)")
                })
                .onChange(of: updateSignal) { _ in
                    Task {
                        await fetchPizza()
                    }
                }
                .toolbar(isPresented ? .hidden : .visible, for: .tabBar)
        }
    }
    
    struct FullScreenCoverModifier: ViewModifier {
        @Binding var isPresented: Bool
        @Binding var seletedTodo: Todo
        func body(content: Content) -> some View {
            content.fullScreenCover(isPresented: $isPresented) {
                AddTodoView(isShowingEditTodo: $isPresented,
                            todo: $seletedTodo)
            }
        }
    }
    
    private func startTyping() {
        if currentIndex < fullText.count {
            let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
            animatedText.append(fullText[index])
            currentIndex += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                startTyping()
            }
        }
    }
}

private struct NavigationModifier: ViewModifier {

    @Binding var tabBarvisibility: Visibility
        
    func body(content: Content) -> some View {
        content
            .navigationTitle(Date().format("MM월 dd일 EEEE"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarBuillder }
            .toolbar( tabBarvisibility, for: .tabBar)
    }
    
    // MARK: Navigation Tool Bar , MissionView, RegisterView
    @ToolbarContentBuilder
    var toolbarBuillder: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            NavigationLink {
                RegisterView(willUpdateTodo: .constant(Todo.sample),
                             successDelete: .constant(false),
                             isShowingEditTodo: .constant(false),
                             isModify: false)
                .backKeyModifier(tabBarvisibility: $tabBarvisibility)
            } label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(Color.pickle)
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink {
                MissionView()
                    .backKeyModifier(tabBarvisibility: $tabBarvisibility)
            } label: {
                Image("mission")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationStack {
            _ = PreviewsContainer.setUpDependency()
            let todo = TodoStore()
            let pizza = PizzaStore()
            let user = UserStore()
            let mission = MissionStore()
            _ = PreviewsContainer.dependencySetting(pizza: pizza,
                                                        user: user,
                                                        todo: todo,
                                                        mission: mission)
            HomeView()
                .environmentObject(todo)
                .environmentObject(pizza)
                .environmentObject(user)
                .environmentObject(mission)
                .environmentObject(NotificationManager())
        }
    }
}
