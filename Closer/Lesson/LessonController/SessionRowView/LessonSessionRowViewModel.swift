//
//  LessonSessionRowViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/9/22.
//

import SwiftUI
import FirebaseFirestore

class LessonSessionRowViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    var session: FirestoreSession?
    
    @Published var partner: Partner? = nil
    
    @Published var doShowIviteSheet: Bool = false
    @Published var doShowQuitConfirmation: Bool = false
    @Published var doShowRemovePartnerConfirmation: Bool = false
    
    func loadViewModel(for session: FirestoreSession?) {
        
        self.session = session
        
        if let session = session, let user = AuthManager.shared.firestoreUser {
            
            var partnerId = ""
            var partnerName = ""
            var partnerJoined: Bool = false
            var partnerStarted: Bool = false
            var partnerRole: UserRole? = nil
            
            if user.role == .student {
                partnerId = session.teacherId ?? ""
                partnerName = session.teacherName ?? ""
                partnerJoined = session.teacherJoined
                partnerStarted = session.teacherStarted
                partnerRole = .teacher
            } else if user.role == .teacher {
                partnerId = session.studentId ?? ""
                partnerName = session.studentName ?? ""
                partnerJoined = session.studentJoined
                partnerStarted = session.studentStarted
                partnerRole = .student
            }
            
            if !partnerId.isEmpty, let partnerRole = partnerRole {
                partner = Partner(
                    uid: partnerId,
                    name: partnerName,
                    joined: partnerJoined,
                    started: partnerStarted,
                    role: partnerRole
                )
                
                ImageHelpers.loadImage(for: partnerId, in: "avatars") { image in
                    self.partner?.photo = image
                }
                
            } else {
                partner = nil
            }
        }
    }
    
    func removePartner() {
        // TODO: show alert first
        
        if let session = session, let user = AuthManager.shared.firestoreUser {
            
            var partnerIdFieldName: String = ""
            var partnerNameFieldName: String = ""
            var partnerJoinedFieldName: String = ""
            var partnerStartedFieldName: String = ""
            
            if user.role == .student {
                partnerIdFieldName = "teacherId"
                partnerNameFieldName = "teacherName"
                partnerJoinedFieldName = "teacherJoined"
                partnerStartedFieldName = "teacherStarted"
            } else if user.role == .teacher {
                partnerIdFieldName = "studentId"
                partnerNameFieldName = "studentName"
                partnerJoinedFieldName = "studentJoined"
                partnerStartedFieldName = "studentStarted"
            } else {
                // Report a bug
                return
            }
            
            db.collection("sessions").document(session.uid).setData(
                [
                    partnerIdFieldName : FieldValue.delete(),
                    partnerNameFieldName: FieldValue.delete(),
                    partnerJoinedFieldName: FieldValue.delete(),
                    partnerStartedFieldName: FieldValue.delete()
                ],
                merge: true
            ) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    }
                }
        }
    }
    
    func quitSession() {
        if let session = session, let user = AuthManager.shared.firestoreUser {
            
            // Note:
            // if partner hasn’t started yet, delete the whole session
            let partnerJoined = user.role == .student ? session.teacherJoined : session.studentJoined
            if !partnerJoined {
                db.collection("sessions").document(session.uid).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    }
                }
            } else {
                var userIdFieldName: String = ""
                var userNameFieldName: String = ""
                var userJoinedFieldName: String = ""
                var userStartedFieldName: String = ""
                
                if user.role == .student {
                    userIdFieldName = "studentId"
                    userNameFieldName = "studentName"
                    userJoinedFieldName = "studentJoined"
                    userStartedFieldName = "studentStarted"
                } else if user.role == .teacher {
                    userIdFieldName = "teacherId"
                    userNameFieldName = "teacherName"
                    userJoinedFieldName = "teacherJoined"
                    userStartedFieldName = "teacherStarted"
                } else {
                    // Report a bug
                    return
                }
                
                db.collection("sessions").document(session.uid).setData(
                    [
                        userIdFieldName: FieldValue.delete(),
                        userNameFieldName: FieldValue.delete(),
                        userJoinedFieldName: FieldValue.delete(),
                        userStartedFieldName: FieldValue.delete()
                    ],
                    merge: true
                ) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        }
                    }
            }
        }
    }
}
