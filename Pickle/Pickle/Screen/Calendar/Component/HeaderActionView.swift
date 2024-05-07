//
//  HeaderActionView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct HeaderActionView: View {
    
    @ObservedObject var calendarModel: CalendarViewModel
    @Binding var weekToMonth: Bool
    
    var body: some View {
        HStack {
            if calendarModel.currentDay.isToday {
                Text("오늘")
                    .font(.largeTitle)
                    .bold()
            } else {
                Text(calendarModel.currentDay.format("EEEE"))
                    .font(.largeTitle)
                    .bold()
            }
            Spacer()
            
            Button(action: {
                if weekToMonth {
                    calendarModel.currentMonthIndex -= 1
                } else {
                    calendarModel.currentWeekIndex -= 1
                    calendarModel.createPreviousWeek()
                }
                
            }, label: {
                Image(systemName: "chevron.left")
            })
            
            Button(action: {
                calendarModel.resetForTodayButton()
            }, label: {
                Text("오늘")
                    .font(.pizzaBody)
                
            })
            Button(action: {
                if weekToMonth {
                    calendarModel.currentMonthIndex += 1
                } else {
                    calendarModel.currentWeekIndex += 1
                    calendarModel.createNextWeek()
                }
            }, label: {
                Image(systemName: "chevron.right")
            })
            
            Button(action: {
                weekToMonth.toggle()
                calendarModel.resetForTodayButton()
            }, label: {
                weekToMonth == true ? Text("월") : Text("주")
                    .font(.headline)
                    .bold()
            })
            .padding(.horizontal, 1)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 50))
        }
    }
}
