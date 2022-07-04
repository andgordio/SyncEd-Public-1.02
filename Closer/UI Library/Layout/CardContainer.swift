//
//  CardContainer.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/21/22.
//

import SwiftUI

struct CardContainer: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color("bg-primary"))
            )
            .padding(8)
    }
}
extension View {
    func cardContainer() -> some View {
    self.modifier(CardContainer())
  }
}
