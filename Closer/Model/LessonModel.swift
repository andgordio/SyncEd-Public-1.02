//
//  Lesson.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import Foundation

enum LessonLevel: String, CaseIterable {
    
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    public var uppercasedName: String {
        switch self {
        case .beginner:
            return "BEGINNER"
        case .intermediate:
            return "INTERMEDIATE"
        case .advanced:
            return "ADVANCED"
        }
    }
    
    public var capitalizedName: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .intermediate:
            return "Intermediate"
        case .advanced:
            return "Advanced"
        }
    }
}

struct Lesson {
    let uid: String
    let name: String
    let description: String
    let level: LessonLevel
}
