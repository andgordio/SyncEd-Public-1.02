//
//  LessonViewModifiers.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/9/22.
//

import SwiftUI

struct LessonCoverImageFrame: ViewModifier {
    let geometry: GeometryProxy
    let paddingFactor: CGFloat
    func body(content: Content) -> some View {
        content
            .frame(
                width: geometry.size.width * (1 - paddingFactor),
                height: 320
            )
    }
}

struct LessonCoverImagePadding: ViewModifier {
    let geometry: GeometryProxy
    let paddingFactor: CGFloat
    func body(content: Content) -> some View {
        content
            .padding(
                .horizontal,
                geometry.size.width * (paddingFactor / 2)
            )
            .padding(.bottom, -40)
            .padding(.top, 20)
    }
}


extension View {
    
    func lessonCoverImageFrame(_ geometry: GeometryProxy, _ paddingFactor: CGFloat) -> some View {
        self.modifier(LessonCoverImageFrame(geometry: geometry, paddingFactor: paddingFactor))
    }
    
    func lessonCoverImagePadding(_ geometry: GeometryProxy, _ paddingFactor: CGFloat) -> some View {
        self.modifier(LessonCoverImagePadding(geometry: geometry, paddingFactor: paddingFactor))
    }
}
