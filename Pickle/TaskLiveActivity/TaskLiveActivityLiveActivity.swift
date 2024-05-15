//
//  TaskLiveActivityLiveActivity.swift
//  TaskLiveActivity
//
//  Created by 박형환 on 5/8/24.
//

import ActivityKit
import WidgetKit
import SwiftUI
import PickleCommon
import AppIntents

@available(iOS 17.0, *)
public struct PizzaTaskLiveActivityAttributes: ActivityAttributes {
    var todoId: String
    var todoName: String
    
    public struct ContentState: Codable, Hashable {
        var startInterval: TimeInterval
        var endInterval: TimeInterval
    }
}

public enum TaskMode: Codable {
    case increasing
    case decreasing
    case end
}

@available(iOS 17.0, *)
public struct TaskLiveActivityAttributes: ActivityAttributes {
    public var taskID: String
    public var taskName: String
    
    public struct ContentState: Codable, Hashable {
        var taskMode: TaskMode
        var taskTime: ClosedRange<Date>
    }
}

@available(iOS 17.0, *)
struct TaskLiveActivityLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TaskLiveActivityAttributes.self) { context in
            VStack(alignment: .leading) {
                HStack {
                    LiveActivityCircleView(
                        width: UIScreen.main.bounds.width * 0.25,
                        workoutDateRange: context.state.taskTime,
                        mode: context.state.taskMode
                    )
                    .padding(.vertical, 10)
                    .padding(.leading, 15)
                    
                    LiveActivityCountDownView(
                        state: context.state,
                        content: context.attributes.taskName
                    )
                }
            }
            .activitySystemActionForegroundColor(Color.clear)
            .onAppear {
                try? Font.register(fileNameString: "Chab", type: "otf")
                try? Font.register(fileNameString: "NanumSquareNeoOTF-Rg", type: "otf")
            }
            
        } dynamicIsland: { context in
            DynamicIsland {
                
                DynamicIslandExpandedRegion(.leading) {
                    Image(uiImage: PizzaPickle.getImage() ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44)
                        .foregroundColor(.white)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.taskName)
                        .font(.pizzaTimerNum)
                        .padding(.leading, 15)
                        .padding(.trailing, 20)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                        .background(
                            ZStack(alignment: .trailing) {
                                Capsule()
                                    .fill(Color.pickle.opacity(0.6))
                            }
                        )
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center) {
                        ModeTimerText(
                            state: context.state,
                            font: .pizzaTimerNum
                        )
                    }
                }
            } compactLeading: {
                Text("피자")
                    .font(.liveActivityLeading)
                    .foregroundStyle(Color.pickle)
                    .padding(.leading, 2)
                
            } compactTrailing: {
                TimerProgressView(
                    workoutDateRange: context.state.taskTime,
                    mode: context.state.taskMode
                )
                .frame(width: 25, height: 25) // 크기 조정.padding(.leading, 1)
            } minimal: {
                TimerProgressView(
                    workoutDateRange: context.state.taskTime,
                    mode: context.state.taskMode
                )
                .frame(width: 25, height: 25) // 크기 조정
            }
            .keylineTint(Color.pickle)
        }
    }
}

@available(iOS 17.0, *)
extension TaskLiveActivityAttributes {
    fileprivate static var preview: TaskLiveActivityAttributes {
        TaskLiveActivityAttributes(taskID: UUID().uuidString, taskName: "환형")
    }
}

@available(iOS 17.0, *)
extension TaskLiveActivityAttributes.ContentState {
    fileprivate static var decreasing: TaskLiveActivityAttributes.ContentState {
        TaskLiveActivityAttributes.ContentState(
            taskMode: .decreasing,
            taskTime: Date.now...Date(timeInterval: 60 * 180, since: Date.now)
        )
    }
     
     fileprivate static var increasing: TaskLiveActivityAttributes.ContentState {
         TaskLiveActivityAttributes.ContentState(
            taskMode: .increasing,
            taskTime: Date.now...Date(timeInterval: 60 * 180, since: Date.now)
         )
     }
}

@available(iOS 17.0, *)
#Preview("Notification", as: .content, using: TaskLiveActivityAttributes.preview) {
   TaskLiveActivityLiveActivity()
        
} contentStates: {
    TaskLiveActivityAttributes.ContentState.decreasing
    TaskLiveActivityAttributes.ContentState.increasing
}
