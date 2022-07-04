//
//  FormTextValidation.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI

struct FormTextValidation: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .foregroundColor(.red)
            .font(.system(size: 14))
    }
}

extension View {
    func formTextValidation() -> some View {
    self.modifier(FormTextValidation())
  }
}
