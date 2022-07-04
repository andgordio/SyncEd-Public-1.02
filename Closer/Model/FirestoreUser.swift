//
//  FirestoreUser.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/28/22.
//

import Foundation

public struct FirestoreUser {
    var uid: String
    var phoneNumber: String
    var role: UserRole?
    var name: String
    var didCompleteOnboarding: Bool
}

enum UserRole: String, CaseIterable {
    case student = "student"
    case teacher = "teacher"
    
    public var capitalizedName: String {
        switch self {
        case .student:
            return "Student"
        case .teacher:
            return "Teacher"
        }
    }
    
    public var systemIconName: String {
        switch self {
        case .student:
            return "graduationcap.fill"
        case .teacher:
            return "briefcase.fill"
        }
    }
}
