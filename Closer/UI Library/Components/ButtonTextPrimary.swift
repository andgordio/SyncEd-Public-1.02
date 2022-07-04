//
//  ButtonTextPrimary.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI

struct ButtonTextPrimary: View {
    
    var text: String
    var isLoading: Bool
    var isDangerous: Bool
    
    init(text: String, isLoading: Bool) {
        self.text = text
        self.isLoading = isLoading
        self.isDangerous = false
    }
    
    init(text: String, isLoading: Bool, isDangerous: Bool) {
        self.text = text
        self.isLoading = isLoading
        self.isDangerous = isDangerous
    }
    
    var body: some View {
        Text(isLoading ? "Loading" : text)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isDangerous ? .red : .blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(isLoading ? 0.4 : 1)
    }
}

struct ButtonTextPrimary_Previews: PreviewProvider {
    static var previews: some View {
        ButtonTextPrimary(text: "Submit", isLoading: false)
    }
}
