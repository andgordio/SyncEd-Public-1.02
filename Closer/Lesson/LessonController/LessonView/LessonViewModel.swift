//
//  LessonsViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class LessonViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    let firestoreUser = AuthManager.shared.firestoreUser
    
    @Published var isLoadingSessions = true
    @Published var sessions: [FirestoreSession] = []
    
    @Published var cover: Image? = nil
    
    @Published var sessionForInvite: FirestoreSession? = nil
    @Published var doShowIviteSheet = false
    
    func loadSessions(for lesson: Lesson) {
        
        ImageHelpers.loadImage(for: lesson.uid, in: "lessonCovers") { image in
            self.cover = image
        }
        
        guard let firestoreUser = firestoreUser else {
            print("No user found. Authentication error")
            return
        }
        
        var userIdFieldName: String = ""
        if firestoreUser.role == .student {
            userIdFieldName = "studentId"
        } else if firestoreUser.role == .teacher {
            userIdFieldName = "teacherId"
        } else {
            // Report a bug
            self.isLoadingSessions = false
            return
        }
        
        let query = db.collection("sessions")
            .whereField(userIdFieldName, isEqualTo: firestoreUser.uid)
            .whereField("lessonId", isEqualTo: lesson.uid)
            .order(by: "dateCreated")
        
        query.addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
                self.isLoadingSessions = false
            } else {
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(err!)")
                    self.isLoadingSessions = false
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    
                    var dateCreated: Date? = nil
                    if let dateCreatedTimestamp = diff.document.data()["dateCreated"] as? Timestamp {
                        dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
                    }
                    
                    var playerLastUpdated: Date? = nil
                    if let playerUpdatedTimestamp = diff.document.data()["playerLastUpdated"] as? Timestamp {
                        playerLastUpdated = Date(timeIntervalSince1970: TimeInterval(playerUpdatedTimestamp.seconds))
                    }
                    
                    let session = FirestoreSession(
                        uid: diff.document.documentID,
                        dateCreated: dateCreated,
                        lessonId: lesson.uid,
                        
                        studentId: diff.document.data()["studentId"] as? String,
                        studentName: diff.document.data()["studentName"] as? String,
                        studentStarted: diff.document.data()["studentStarted"] as? Bool ?? false,
                        studentJoined: diff.document.data()["studentJoined"] as? Bool ?? false,
                        studentOnPage: diff.document.data()["studentOnPage"] as? Int,
                        
                        teacherId: diff.document.data()["teacherId"] as? String,
                        teacherName: diff.document.data()["teacherName"] as? String,
                        teacherStarted: diff.document.data()["teacherStarted"] as? Bool ?? false,
                        teacherJoined: diff.document.data()["teacherJoined"] as? Bool ?? false,
                        teacherOnPage: diff.document.data()["teacherOnPage"] as? Int,
                        
                        playerIsPlaying: diff.document.data()["playerIsPlaying"] as? Bool,
                        playerFileName: diff.document.data()["playerFileName"] as? String,
                        playerStartTime: diff.document.data()["playerStartTime"] as? Double,
                        playerLastUpdated: playerLastUpdated
                    )
                    
                    let index = self.sessions.firstIndex(where: { $0.uid == session.uid })
                    if let index = index {
                        if (diff.type == .modified) {
                            self.sessions[index] = session
                        }
                        else if (diff.type == .removed) {
                            self.sessions.remove(at: index)
                        }
                    } else {
                        // ~ Note ~
                        // For some reasome Firestore returns same object
                        // of diff.type == .added multiple times. The if/else check above
                        // confirms that object doesn’t exists in sessions already.
                        if (diff.type == .added) {
                            self.sessions.append(session)
                        }
                    }
                }
                self.isLoadingSessions = false
            }
        }
    }
    
    func createSession(for lesson: Lesson, with partner: Partner? = nil) {
        
        guard let firestoreUser = firestoreUser else {
            print("No user found. Authentication error")
            return
        }
        
        var data: [String: Any] = [
            "dateCreated": FieldValue.serverTimestamp(),
            "isCompleted": false,
            "studentStarted": false,
            "teacherStarted": false,
            "lessonId": lesson.uid
        ]
        let role = firestoreUser.role
        if role == .student {
            data["studentId"] = firestoreUser.uid
            data["studentName"] = firestoreUser.name
            data["studentJoined"] = true
            data["teacherJoined"] = false
            data["teacherId"] = partner?.uid ?? ""
            data["teacherName"] = partner?.name ?? ""
        } else if role == .teacher {
            data["teacherId"] = firestoreUser.uid
            data["teacherName"] = firestoreUser.name
            data["teacherJoined"] = true
            data["studentJoined"] = false
            data["studentId"] = partner?.uid ?? ""
            data["studentName"] = partner?.name ?? ""
        }
        
        db.collection("sessions").addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
}
