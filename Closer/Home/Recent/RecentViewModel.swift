//
//  RecentViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI
import FirebaseFirestore

class RecentViewModel: ObservableObject {
    
    @Published var recent: [Invitation] = []
    
    public var db = Firestore.firestore()
    
    func loadRecent() {
        if let user = AuthManager.shared.firestoreUser {

            var userIdFieldName: String = ""
            var userJoinedFieldName: String = ""
            var partnerIdFieldName: String = ""
            var partnerNameFieldName: String = ""
            
            if user.role == .student {
                userIdFieldName = "studentId"
                userJoinedFieldName = "studentJoined"
                partnerIdFieldName = "teacherId"
                partnerNameFieldName = "teacherName"
            } else if user.role == .teacher {
                userIdFieldName = "teacherId"
                userJoinedFieldName = "teacherJoined"
                partnerIdFieldName = "studentId"
                partnerNameFieldName = "studentName"
            }

            db
                .collection("sessions")
                .whereField(userIdFieldName, isEqualTo: user.uid)
                .whereField(userJoinedFieldName, isEqualTo: true)
                .addSnapshotListener { querySnapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        guard let snapshot = querySnapshot else {
                            print("Error fetching snapshots: \(err!)")
                            return
                        }
                        snapshot.documentChanges.forEach { diff in
                            var dateCreated: Date? = nil
                            if let postTimestamp = diff.document.data()["dateCreated"] as? Timestamp {
                                dateCreated = Date(timeIntervalSince1970: TimeInterval(postTimestamp.seconds))
                            }
                            
                            if let lessonId = diff.document.data()["lessonId"] as? String {
                                
                                self.db
                                    .collection("lessons")
                                    .document(lessonId)
                                    .getDocument { document, error in
                                    if let error = error {
                                        print("Error getting documents: \(error)")
                                    } else {
                                        guard let document = document else {
                                            print("Error fetching snapshots: \(error!)")
                                            return
                                        }
                                        let lesson = Lesson(
                                            uid: document.documentID,
                                            name: document.data()?["name"] as? String ?? "Unnamed lesson",
                                            description: document.data()?["description"] as? String ?? "",
                                            level: LessonLevel(rawValue: document.data()?["level"] as? String ?? "beginner") ?? LessonLevel.beginner
                                        )
                                        
                                        var invitation = Invitation(
                                            sessionId: diff.document.documentID,
                                            sessionDateCreated: dateCreated,
                                            partnerId: diff.document.data()[partnerIdFieldName] as? String ?? "",
                                            partnerName: diff.document.data()[partnerNameFieldName] as? String ?? "",
                                            lesson: lesson,
                                            isHidden: false
                                        )
                                        let index = self.recent.firstIndex(where: { $0.sessionId == invitation.sessionId })
                                        if let index = index {
                                            if (diff.type == .modified) {
                                                self.recent[index] = invitation
                                            }
                                            else if (diff.type == .removed) {
                                                invitation.isHidden = true
                                                self.recent[index] = invitation
                                            }
                                        } else {
                                            // ~ Note ~
                                            // For some reasome Firestore returns same object
                                            // of type .added multiple times. Placing this check
                                            // here confirms that object doesn???t exists in sessions already.
                                            if (diff.type == .added) {
                                                self.recent.append(invitation)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }
    }
}
