//
//  CalendarView.swift
//  Pickle
//
//  Created by 최소정 on 2023/09/25.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var missionStore: MissionStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var navigationStore: NavigationStore
    @Environment(\.scrollEnable) var scrollEnable: Binding<ScrollEnableKey>
    
    @StateObject private var calendarModel: CalendarViewModel = CalendarViewModel()
    
    @State private var filteredTasks: [Todo]?
    @State private var filteredTodayMission: [TimeMission]?
    @State private var weekToMonth: Bool = false
    @State private var offset: CGSize = CGSize()
    @State private var todayPieceOfPizza: Int = 0
    @State private var pizzaSummarySheet: Bool = false
    @State private var todayCompletedTasks: Int = 0
    @State private var wakeUpMission: Int = 0
    @State private var walkMission: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                CalendarHeaderView(calendarModel: calendarModel,
                                   weekToMonth: $weekToMonth)
                
                TodayPizzaSummaryView(todayPieceOfPizza: $todayPieceOfPizza,
                                      pizzaSummarySheet: $pizzaSummarySheet)
                
               taskView(tasks: filteredTasks ?? [])
                .scrollIndicators(.hidden)
                .frame(width: geometry.size.width)
            }
        }
        .task {
            await todoStore.fetch()
        }
        .onAppear {
            Log.debug("CalendarView onAppear")
            calendarModel.resetForTodayButton()
            filterTodayTasks(todo: todoStore.todos)
            todayPizzaCount(todayTasks: filteredTasks ?? [],
                            timeMissions: missionStore.timeMissions,
                            behaviorMissions: missionStore.behaviorMissions)
        }
        
        .onChange(of: calendarModel.currentDay) { _ in
            filterTodayTasks(todo: todoStore.todos)
            let time = missionStore.fetch().0
            let mission = missionStore.fetch().1
            todayPizzaCount(todayTasks: filteredTasks ?? [],
                            timeMissions: time,
                            behaviorMissions: mission)
        }
        .sheet(isPresented: $pizzaSummarySheet) {
            TodayPizzaSheetView(currentDay: calendarModel.currentDay,
                                todayPieceOfPizza: todayPieceOfPizza,
                                walkMission: walkMission,
                                todayCompletedTasks: todayCompletedTasks)
                .padding()
            Spacer()
                .presentationDetents([.height(300)])
        }
    }
    
    // MARK: - TaskView
    func taskView(tasks: [Todo]) -> some View {
        ScrollView(.vertical) {
            ForEach(tasks) { task in
                TaskRowView(task: task)
            }
        }
    }
    
    // MARK: - Filter Today Tasks
    func filterTodayTasks(todo: [Todo]?) {
        let calendar  = Calendar.current
        guard let afterTodo = todo else { return }
        let filtered = afterTodo.filter { calendar.isDate($0.startTime, inSameDayAs: calendarModel.currentDay)
        }
        
        filteredTasks =  filtered
        
    }
    
    func filterTodayTimeMission(mission: [TimeMission]) {
        let calendar  = Calendar.current
        
        let filtered = mission.filter { calendar.isDate($0.date, inSameDayAs: calendarModel.currentDay)
        }
        
        filteredTodayMission  =  filtered
        
    }
    
    func todayPizzaCount(todayTasks: [Todo],
                         timeMissions: [TimeMission],
                         behaviorMissions: [BehaviorMission]) {
        let calendar  = Calendar.current
        
        todayCompletedTasks = todayTasks.filter { $0.status == .done
        }.count
        
        let firstStepTimeMission =  timeMissions.filter { calendar.isDate($0.date, inSameDayAs: calendarModel.currentDay)
        }
        
        wakeUpMission = firstStepTimeMission.filter { $0.status == .done
        }.count
        
        let firstStepBehaviorMission =  behaviorMissions.filter { calendar.isDate($0.date, inSameDayAs: calendarModel.currentDay)
        }
        
        let tempBehaviorMissionTask0 = firstStepBehaviorMission.filter { $0.status == .done
            
        }
        
        let tempBehaviorMissionTask1 = firstStepBehaviorMission.filter {  $0.status1 == .done
            
        }
        
        let tempBehaviorMissionTask2 = firstStepBehaviorMission.filter {  $0.status2 == .done
            
        }
        walkMission = tempBehaviorMissionTask0.count +  tempBehaviorMissionTask1.count + tempBehaviorMissionTask2.count
        
        let finalPizzaCount = todayCompletedTasks + wakeUpMission + walkMission
        
        todayPieceOfPizza = finalPizzaCount
    }
    
}

#Preview {
    
    CalendarView()
        .environmentObject(TodoStore())
        .environmentObject(UserStore())
        .environmentObject(MissionStore())
    
}
