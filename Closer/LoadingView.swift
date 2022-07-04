//
//  LoadingView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/21/22.
//

import SwiftUI

struct LoadingView: View {
    @State private var isRotated = false
    
    let duration: Double = 1.4
    let degrees: Double = 720
    let imageSize: CGFloat = 56
    
    var body: some View {
        VStack {
            Image("LoadingIndicator")
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .rotationEffect(.degrees(isRotated ? degrees : 0))
                .animation(
                    Animation
                        .easeInOut(duration: duration)
                        .repeatForever(autoreverses: false),
                    value: isRotated
                )
        }
        .onAppear {
            isRotated = true
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
