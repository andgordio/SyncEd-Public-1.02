//
//  LessonLevelBadgeView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/7/22.
//

import SwiftUI

struct LessonLevelBadgeView: View {
    
    let level: LessonLevel
    
    let iconName: String
    let iconColor: Color
    let title: String
    
    init(_ level: LessonLevel) {
        self.level = level
        switch level {
        case .beginner:
            title = "Beginner"
            iconName = "die.face.1.fill"
            iconColor = .green
        case .intermediate:
            title = "Intermediate"
            iconName = "die.face.2.fill"
            iconColor = .orange
        case .advanced:
            title = "Advanced"
            iconName = "die.face.3.fill"
            iconColor = .red
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .rotationEffect(.degrees(-12))
                .scaleEffect(0.82)
            Text(title)
                .fontWeight(.medium)
        }
        .foregroundColor(iconColor)
    }
}

struct LessonLevelBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        LessonLevelBadgeView(.beginner)
    }
}
