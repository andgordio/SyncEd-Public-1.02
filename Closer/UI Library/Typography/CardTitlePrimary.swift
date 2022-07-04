//
//  CardTitlePrimary.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI

struct CardTitlePrimary: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension View {
    func cardTitlePrimary() -> some View {
    self.modifier(CardTitlePrimary())
  }
}
