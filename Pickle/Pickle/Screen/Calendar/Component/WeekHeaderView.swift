//
//  WeekHeaderView.swift
//  Pickle
//
//  Created by 박형환 on 5/6/24.
//

import SwiftUI

struct WeekHeaderView: View {
    var body: some View {
        HStack {
            let days: [String] = ["일", "월", "화", "수", "목", "금", "토"]
            ForEach(days, id: \.self) { day in
                Text(day)
                    .frame(maxWidth: .infinity)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
    }
}
