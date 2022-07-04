//
//  FormControlPrimary.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI

struct FormControlPrimary: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 44)
            .padding(.horizontal)
            .background(Color("bg-secondary"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func formControlPrimary() -> some View {
    self.modifier(FormControlPrimary())
  }
}
