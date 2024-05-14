//
//  PizzaLiveActivity.swift
//  Pickle
//
//  Created by 박형환 on 5/8/24.
//

import SwiftUI
import ActivityKit

final class PizzaLiveActivity: ObservableObject {
    
    private var activity: Any?
    
    @available(iOS 17.0, *)
    private var _activity: Activity<TaskLiveActivityAttributes>? {
        get { activity as? Activity<TaskLiveActivityAttributes> }
        set { activity = newValue }
    }
    
    func startTimerActivity(taskID: String,
                            content: String,
                            closedRange: ClosedRange<Date>) {
        
        if #available(iOS 17.0, *) {
            let attributes
            = TaskLiveActivityAttributes(
                taskID: taskID,
                taskName: content
            )
            
            let state
            = TaskLiveActivityAttributes.ContentState(
                taskMode: .decreasing,
                taskTime: closedRange
            )
            do {
                _activity =
                try Activity<TaskLiveActivityAttributes>.request(
                    attributes: attributes,
                    contentState: state,
                    pushType: nil
                )
            } catch {
                assert(false, "Acitivity Fail")
            }
        }
    }
    
    func updateActivity(range: ClosedRange<Date>) {
        if #available(iOS 17.0, *) {
            Task {
                guard let id = _activity?.id else {
                    return
                }
                
                guard let activity = Activity<TaskLiveActivityAttributes>.activities.first(where: { $0.id == id }) else {
                    return
                }
                
                let state
                = TaskLiveActivityAttributes.ContentState(
                    taskMode: .increasing,
                    taskTime: range
                )
                
                await activity.update(using: state)
            }
        } else {
            return
        }
    }
    
    @available(iOS 17.0, *)
    func stopTimerActivity() async {
        let finalContent
        = TaskLiveActivityAttributes.ContentState(
            taskMode: .end,
            taskTime: Date()...Date()
        )
        let dismissalPolicy: ActivityUIDismissalPolicy = .immediate
        await _activity?.end(
            ActivityContent(
                state: finalContent,
                staleDate: nil
            ),
            dismissalPolicy: dismissalPolicy
        )
    }
}
