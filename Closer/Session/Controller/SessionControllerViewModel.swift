//
//  SessionControllerViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/3/22.
//

import SwiftUI
import FirebaseFirestore

struct LessonSection {
    var uid: String
    var name: String
    var order: Int
    var coverUrl: String?
}

struct LessonTask {
    var uid: String
    var sectionId: String
    var name: String
    var body: String
    var order: Int
    var type: LessonTaskType
}

enum LessonTaskType: String {
    case text = "text"
    case audio = "audio"
    case listPlain = "listPlain"
    case textInput = "textInput"
}

class SessionControllerViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    let user = AuthManager.shared.firestoreUser
    
    @Published var session: FirestoreSession? = nil
    @Published var sections: [LessonSection] = []
    @Published var tasks: [LessonTask] = []
    
    @Published var myPageIndex: Int = 0
    @Published var isLoading = true
    
    @Published var partnerPhoto: Image?
    
    func loadViewModel(sessionId: String, lessonId: String) {
        
        isLoading = true
        
        addSessionListener(sessionId: sessionId, lessonId: lessonId)
        
        var sectionsToLoad = 0
        
        self.db
            .collection("lessons")
            .document(lessonId)
            .collection("sections")
            .order(by: "order")
            .getDocuments { snapshot, err in
                if let err = err {
                    print("Error getting documents: \(err.localizedDescription)")
                    self.isLoading = false
                } else {
                    guard let snapshot = snapshot else {
                        print("Error fetching snapshots: \(err?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    if snapshot.documents.isEmpty {
                        self.isLoading = false
                    } else {
                        sectionsToLoad = snapshot.documents.count
                        snapshot.documents.forEach { document in
                            
                            self.loadTasksFor(lessonId: lessonId, sectionId: document.documentID)
                            
                            let section = LessonSection(
                                uid: document.documentID,
                                name: document.data()["name"] as? String ?? "Unknown section",
                                order: document.data()["order"] as? Int ?? 0,
                                coverUrl: document.data()["coverUrl"] as? String
                            )
                            self.sections.append(section)
                            sectionsToLoad -= 1
                            if sectionsToLoad == 0 {
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
    }
    
    func addSessionListener(sessionId: String, lessonId: String) {
        db
            .collection("sessions")
            .document(sessionId)
            .addSnapshotListener { snapshot, err in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    guard let document = snapshot else {
                        print("Error fetching snapshots: \(err!)")
                        return
                    }
                    var dateCreated: Date? = nil
                    if let dateCreatedTimestamp = document.data()?["dateCreated"] as? Timestamp {
                        dateCreated = Date(timeIntervalSince1970: TimeInterval(dateCreatedTimestamp.seconds))
                    }
                    var playerLastUpdated: Date? = nil
                    if let playerUpdatedTimestamp = document.data()?["playerLastUpdated"] as? Timestamp {
                        playerLastUpdated = Date(timeIntervalSince1970: TimeInterval(playerUpdatedTimestamp.seconds))
                    }
                    let session = FirestoreSession(
                        uid: document.documentID,
                        dateCreated: dateCreated,
                        lessonId: lessonId,
                        
                        studentId: document.data()?["studentId"] as? String,
                        studentName: document.data()?["studentName"] as? String,
                        studentStarted: document.data()?["studentStarted"] as? Bool ?? false,
                        studentJoined: document.data()?["studentJoined"] as? Bool ?? false,
                        studentOnPage: document.data()?["studentOnPage"] as? Int,
                        
                        teacherId: document.data()?["teacherId"] as? String,
                        teacherName: document.data()?["teacherName"] as? String,
                        teacherStarted: document.data()?["teacherStarted"] as? Bool ?? false,
                        teacherJoined: document.data()?["teacherJoined"] as? Bool ?? false,
                        teacherOnPage: document.data()?["teacherOnPage"] as? Int,
                        
                        playerIsPlaying: document.data()?["playerIsPlaying"] as? Bool,
                        playerFileName: document.data()?["playerFileName"] as? String,
                        playerStartTime: document.data()?["playerStartTime"] as? Double,
                        playerLastUpdated: playerLastUpdated
                    )
                    
                    if self.session == nil, let user = self.user {
                        
                        
                        // Note:
                        // Update the local myPageIndex *only* on initial pull.
                        // It will take care of itself after.
                        var startingPage = 0
                        if user.role == .student {
                            startingPage = session.studentOnPage ?? 0
                        } else {
                            startingPage = session.teacherOnPage ?? 0
                        }
                        self.myPageIndex = startingPage
                        self.session = session
                        
                        
                        // Note:
                        // Update my activity status *only* on initial input
                        var imActiveFieldName = ""
                        var imLastActiveFieldName = ""
                        if user.role == .student {
                            imActiveFieldName = "studentIsActive"
                            imLastActiveFieldName = "studentLastActivityTimestamp"
                        } else {
                            imActiveFieldName = "teacherIsActive"
                            imLastActiveFieldName = "teacherLastActivityTimestamp"
                        }
                        self.db
                            .collection("sessions")
                            .document(sessionId)
                            .setData([
                                imActiveFieldName: true,
                                imLastActiveFieldName: FieldValue.serverTimestamp()
                            ], merge: true)
                    }
                    
                    // Note:
                    // If the diff has a different myPageIndex, add a short pause before updating the model.
                    // This prevents from lags appearing when swiping between pages due to model updating
                    // in the middle of the swipe.
                    if let originalSession = self.session, let user = self.user {
                        if (
                            (user.role == .student) && (originalSession.studentOnPage != session.studentOnPage)
                            ||
                            (user.role == .teacher) && (originalSession.teacherOnPage != session.teacherOnPage)
                        ) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                                self.session = session
                            }
                        } else {
                            self.session = session
                        }
                    }
                }
            }
    }
    
    func loadTasksFor(lessonId: String, sectionId: String) {
        let refPath = db
            .collection("lessons")
            .document(lessonId)
            .collection("sections")
            .document(sectionId)
            .collection("tasks")
        refPath.getDocuments { snapshot, err in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(err?.localizedDescription ?? "Unknown error")")
                return
            }
            if snapshot.documents.isEmpty {
                //
            } else {
                snapshot.documents.forEach { document in
                    let task = LessonTask(
                        uid: document.documentID,
                        sectionId: sectionId,
                        name: document.data()["name"] as? String ?? "",
                        body: document.data()["body"] as? String ?? "",
                        order: document.data()["order"] as? Int ?? 0,
                        type: LessonTaskType(rawValue: document.data()["type"] as? String ?? "text") ?? LessonTaskType.text
                    )
                    self.tasks.append(task)
                }
            }
        }
    }
    
    func updateMyPage(to index: Int) {
        if let user = user, let session = session {
            let myPageFieldName = user.role == .student ? "studentOnPage" : "teacherOnPage"
            db.collection("sessions").document(session.uid).setData([
                myPageFieldName: index
            ], merge: true)
        }
    }
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    func reactivateMe() {
        if let user = user, let session = session {
            var imActiveFieldName = ""
            var imLastActiveFieldName = ""
            if user.role == .student {
                imActiveFieldName = "studentIsActive"
                imLastActiveFieldName = "studentLastActivityTimestamp"
            } else {
                imActiveFieldName = "teacherIsActive"
                imLastActiveFieldName = "teacherLastActivityTimestamp"
            }
            self.db
                .collection("sessions")
                .document(session.uid)
                .setData([
                    imActiveFieldName: true,
                    imLastActiveFieldName: FieldValue.serverTimestamp()
                ], merge: true)
        }
    }
    
    func deactivateMe() {
        if let user = user, let session = session {
            
            var imActiveFieldName = ""
            if user.role == .student {
                imActiveFieldName = "studentIsActive"
            } else {
                imActiveFieldName = "teacherIsActive"
            }
            self.db
                .collection("sessions")
                .document(session.uid)
                .setData([
                    imActiveFieldName: false,
                ], merge: true)
        }
    }
    
    func stopPlayback() {
        PlayerViewController.shared.quitPlayer()
    }
}
