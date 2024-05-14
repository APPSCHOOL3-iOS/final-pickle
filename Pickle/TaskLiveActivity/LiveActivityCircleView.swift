//
//  LiveActivityCircleView.swift
//  Pickle
//
//  Created by 박형환 on 5/9/24.
//

import SwiftUI
import Lottie
import PickleCommon

//  ISSUE
//  I found the issue, Image need to be in a small resolution to be displayed in your live activity/dynamic island.
//
//  Data must be lower or equal than 4kb, here is the official Apple doc:
//
//  The updated dynamic data for both ActivityKit updates and ActivityKit push notifications can’t exceed 4KB in size.
//
//  if let data = UserDefaults.group.object(forKey: "PizzaCharacter") as? Data,
//     let image = UIImage(data: data) {
//      Image(uiImage: image)
//          .resizable()
//          .scaledToFit()
//          .frame(width: UIScreen.main.bounds.width * 0.3)
//          .foregroundColor(.white)
//  }

public extension UserDefaults {
    static var group: UserDefaults {
        let appGroupId = "group.com.realPizza"
        return UserDefaults(suiteName: appGroupId)!
    }
}

internal enum PizzaPickle {
    static func getImage() -> UIImage? {
        if let data = UserDefaults.group.object(forKey: "pizza_pickle") as? Data,
           let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
}

@available(iOS 17.0, *)
public struct LiveActivityCircleView: View {
    
    let width: CGFloat
    let workoutDateRange: ClosedRange<Date>
    
    public var body: some View {
        ZStack {
            TimerProgressView(
                workoutDateRange: workoutDateRange
            )
            .frame(width: width + 25)
            
            Label {
                EmptyView()
                    .foregroundColor(.white)
            } icon: {
                if let image = PizzaPickle.getImage() {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: width)
                            .foregroundColor(.white)
                        
                        // 목표시간 명시
                        Text("120 분")
                            .font(.liveActivityTargetTime)
                            .foregroundColor(.secondary)
                            .offset(y: -10)
                    }
                } else {
                    Text("화이팅")
                }
            }
        }
    }
}
