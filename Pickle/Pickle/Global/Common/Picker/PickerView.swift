//
//  PickerView.swift
//  Pickle
//
//  Created by 박형환 on 10/22/23.
//

import SwiftUI

struct PickerView: View {
    
    @Binding var showTimeMissionModal: Bool
    @Binding var changedWakeupTime: Date
    var title: String
    var action: () -> Void
    var closedRange: ClosedRange<Date>?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button {
                    showTimeMissionModal.toggle()
                } label: {
                    Text("취소")
                        .font(.pizzaBody)
                        .foregroundColor(.pickle)
                }
                Spacer()
                
                Text("\(title) 설정")
                    .font(.nanumEbTitle)
                Spacer()
                
                Button {
                    action()
                } label: {
                    Text("저장")
                        .font(.pizzaBody)
                        .foregroundColor(.pickle)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            
            Divider()
            
            if let closedRange {
                DatePickerUIKit(selection: $changedWakeupTime,
                                in: closedRange,
                                minuteInterval: 1)
            } else {
                DatePicker("시간 선택", selection: $changedWakeupTime,
                           displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
            }
        }
    }
}

extension PickerView {
    static func constraint(start: DateComponents,
                           end: DateComponents) -> ClosedRange<Date> {
        
        let calendar = Calendar.current
        
        let startTime = calendar.date(from: start)!
        let endTime = calendar.date(from: end)!
        
        let range = startTime...endTime
        return range
    }
}
