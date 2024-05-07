//
//  MonthView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct MonthView: View {
    
    @ObservedObject var calendarModel: CalendarViewModel
    @State private var offset: CGSize = CGSize()
    
    var body: some View {
        // MARK: - Montly View
        VStack {
            let dates = calendarModel.extractMonth()
            HStack {
                let colums = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: colums, spacing: 10) {
                    
                    ForEach(dates, id: \.self) { day in
                        
                        if day.day != -1 {
                            Text("\(day.day)")
                                .foregroundStyle(isSameDate(day.date, date2: calendarModel.currentDay) ? .white : .gray)
                                .font(.callout)
                                .frame(width: 30, height: 30)
                                .fontWeight(.semibold)
                                .background {
                                    
                                    if isSameDate(day.date, date2: calendarModel.currentDay) {
                                        Circle()
                                            .fill(Color.pickle)
                                    }
                                    
                                    // MARK: - Indicator to show, which one is Today
                                    if day.date.isToday {
                                        Circle()
                                            .fill(Color.mainRed)
                                            .frame(width: 5, height: 5)
                                            .vSpacing(.bottom)
                                            .offset(y: -33)
                                    }
                                    
                                }
                                .onTapGesture {
                                    calendarModel.currentDay = day.date
                                }
                            
                        } else { Text("") }
                    }
                    .padding(.vertical, 8)
                    .frame(height: 30)
                }
            }
            .onChange(of: calendarModel.currentMonthIndex) { _ in
                calendarModel.currentDay = calendarModel.getCurrentMonth()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.offset = gesture.translation
                }
                .onEnded { gesture in
                    if gesture.translation.width < -50 {
                        
                        calendarModel.currentMonthIndex += 1
                        
                    } else if gesture.translation.width > 50 {
                        
                        calendarModel.currentMonthIndex -= 1
                        
                    }
                    self.offset = CGSize()
                }
        )
        
    }
}
