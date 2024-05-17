//
//  PrimaryButtonModifier.swift
//  Pickle
//
//  Created by 최소정 on 10/19/23.
//

import SwiftUI
import PickleCommon

struct PrimaryButtonModifier: ViewModifier {
    
    let width: CGFloat
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .padding()
            .foregroundStyle(.white)
            .font(.nanumBd)
            .frame(width: width)
            .background(Color.pickle)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(.horizontal, 12)
    }
}
