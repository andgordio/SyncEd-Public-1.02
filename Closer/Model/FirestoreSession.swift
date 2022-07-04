//
//  FirestoreSesion.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/28/22.
//

import Foundation

public struct FirestoreSession: Equatable, Hashable {
    var uid: String
    var dateCreated: Date?
    var lessonId: String
    
    var studentId: String?
    var studentName: String?
    var studentStarted: Bool
    var studentJoined: Bool
    var studentOnPage: Int?
    
    var teacherId: String?
    var teacherName: String?
    var teacherStarted: Bool
    var teacherJoined: Bool
    var teacherOnPage: Int?
    
    var playerIsPlaying: Bool?
    var playerFileName: String?
    var playerStartTime: TimeInterval?
    var playerLastUpdated: Date?
}
