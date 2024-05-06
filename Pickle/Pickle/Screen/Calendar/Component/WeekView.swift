//
//  WeekView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct WeekView: View {
    
    @ObservedObject var calendarModel: CalendarViewModel
    @Binding var offset: CGSize
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(calendarModel.currentWeek, id: \.self) { day in
                VStack(spacing: 8) {
                    Text(day.format("d"))
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(isSameDate(day, date2: calendarModel.currentDay) ? .white : .gray)
                        .frame(width: 30, height: 30)
                        .background {
                            if isSameDate(day, date2: calendarModel.currentDay) {
                                Circle()
                                    .fill(Color.pickle)
                            }
                            if day.isToday {
                                Circle()
                                    .fill(Color.mainRed)
                                    .frame(width: 5, height: 5)
                                    .vSpacing(.bottom)
                                    .offset(y: -63)
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 20.0)
                            .stroke(Color.secondary, lineWidth: 1))
                    
                }
                .hCenter()
                .contentShape(.rect)
                .onTapGesture {
                    
                    // MARK: - Updating Current Date
                    withAnimation(.snappy) {
                        calendarModel.currentDay = day
                        calendarModel.currentWeekIndex = 0
                        
                    }
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width < -50 {
                        withAnimation {
                            calendarModel.currentWeekIndex += 1
                            calendarModel.createNextWeek()
                            
                        }
                        
                    } else if gesture.translation.width > 50 {
                        withAnimation {
                            calendarModel.currentWeekIndex -= 1
                            calendarModel.createPreviousWeek()
                        }
                    }
                    self.offset = CGSize()
                }
        )
    }
}
