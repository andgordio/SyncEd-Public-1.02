//
//  LessonInvitationCardViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/9/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class LessonInvitationCardViewModel: ObservableObject {
    
    let db = Firestore.firestore()
    var session: FirestoreSession?
    
    @Published var partnerName: String = ""
    @Published var partnerPhoto: Image? = nil
    
    func initiateViewModel(for session: FirestoreSession) {
        self.session = session
        if let user = AuthManager.shared.firestoreUser {
            
            var partnerId = ""
            
            switch user.role {
            case .student:
                partnerName = session.teacherName ?? "Unknown"
                partnerId = session.teacherId ?? "unknownUserId"
            case .teacher:
                partnerName = session.studentName ?? "Unknown"
                partnerId = session.studentId ?? "unknownUserId"
            case .none:
                print("Error: loaded a partner without a role")
                return
            }

            ImageHelpers.loadImage(for: partnerId, in: "avatars") { image in
                self.partnerPhoto = image
            }
        }
    }
    
    func acceptInvitation() {
        if let session = session, let user = AuthManager.shared.firestoreUser {
            let meJoined = user.role == .student ? "studentJoined" : "teacherJoined"
            db.collection("sessions").document(session.uid).setData(
                [
                    meJoined: true
                ],
                merge: true
            ) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                }
            }
        }
    }
    
    func declineInvitation() {
        if let session = session, let user = AuthManager.shared.firestoreUser {
            let meId = user.role == .student ? "studentId" : "teacherId"
            let meName = user.role == .student ? "studentName" : "teacherName"
            let meJoined = user.role == .student ? "studentJoined" : "teacherJoined"
            let meStarted = user.role == .student ? "studentStarted" : "teacherStarted"
            db.collection("sessions").document(session.uid).setData(
                [
                    meId: FieldValue.delete(),
                    meName: FieldValue.delete(),
                    meJoined: FieldValue.delete(),
                    meStarted: FieldValue.delete(),
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
