//
//  FullscreenBackground.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI

struct FullscreenBackground<Content: View>: View {
    
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Rectangle().foregroundColor(Color("bg-secondary")).ignoresSafeArea(.all)
            content
        }
    }
}
