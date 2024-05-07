//
//  PizzaCollectionView.swift
//  Pickle
//
//  Created by kaikim on 2023/10/23.
//

import SwiftUI

struct PizzaCollectionView: View {
    
    @Binding var pizza: Pizza
    @Binding var currentPizza: Pizza
    
    var selectedTrigger: Bool {
        if currentPizza.name == pizza.name,
           !currentPizza.lock {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                if pizza.lock {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30, alignment: .center)
                        .zIndex(2)
                }
                
                Image("\(pizza.image)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .clipShape( Circle() )
                    .overlay {
                        Circle()
                            .fill(pizza.lock ? .black.opacity(0.4) : .clear )
                    
                    }
            }
            .frame(width: CGFloat.screenWidth / 3 - 40,
                   height: CGFloat.screenWidth / 3 - 40)
            
            Text("\(pizza.name)")
                .font(.pizzaDescription)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }
}

#Preview {
    NavigationStack {
        PizzaSummaryView()
            .environmentObject(TodoStore())
            .environmentObject(UserStore())
    }
}
