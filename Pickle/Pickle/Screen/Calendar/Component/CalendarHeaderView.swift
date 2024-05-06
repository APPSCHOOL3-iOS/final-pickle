//
//  CalendarHeaderView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct CalendarHeaderView: View {
    @ObservedObject var calendarModel: CalendarViewModel
    @Binding var weekToMonth: Bool
    @State private var offset: CGSize = CGSize()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(calendarModel.currentDay.format("YYYY년 M월 d일"))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                
                HeaderActionView(calendarModel: calendarModel, weekToMonth: $weekToMonth)
                
                WeekHeaderView()
                    .padding(.top, 5)
                
                if weekToMonth {
                    MonthView(calendarModel: calendarModel)
                } else {
                    WeekView(calendarModel: calendarModel, offset: $offset)
                        .padding(.bottom, 5)
                }
            }
            .hLeading()
        }
        .padding(.horizontal)
        .padding(.top, 15)
    }
}
