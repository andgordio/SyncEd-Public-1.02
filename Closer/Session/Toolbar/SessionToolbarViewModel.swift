//
//  SessionToolbarViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/15/22.
//

import SwiftUI
import FirebaseFirestore

class SessionToolbarViewModel: ObservableObject {
    
    let user = AuthManager.shared.firestoreUser
    let db = Firestore.firestore()
    
    @Published var partnerPage: Int?
    func initWatchPartnerPage(session: FirestoreSession) {
        if let user = AuthManager.shared.firestoreUser {
            db
                .collection("sessions")
                .document(session.uid)
                .addSnapshotListener { document, error in
                    if let error = error {
                        print("Error occured trying to add listener to partner’s page index: \(error)")
                    }
                    guard let document = document else {
                        print("Error occured trying to add listener to partner’s page index: Session not found.")
                        return
                    }
                    if user.role == .student {
                        if document.data()?["teacherIsActive"] as? Bool ?? false {
                            self.partnerPage = document.data()?["teacherOnPage"] as? Int
                        } else {
                            self.partnerPage = nil
                        }
                    }
                    else if user.role == .teacher {
                        if document.data()?["studentIsActive"] as? Bool ?? false {
                            self.partnerPage = document.data()?["studentOnPage"] as? Int
                        } else {
                            self.partnerPage = nil
                        }
                    }
                }
        }
    }
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    func checkPartnerIdleTime(session: FirestoreSession) {
        if let user = AuthManager.shared.firestoreUser, partnerPage != nil {
            let ref = db.collection("sessions").document(session.uid)
            ref.getDocument { document, error in
                if let error = error {
                    print("Error occured trying to pull partner’s page index: \(error)")
                }
                guard let document = document else {
                    print("Error occured trying to pull partner’s page index: Session not found.")
                    return
                }
                let now = Date.now
                var timestampFieldName = ""
                var isActiveFieldName = ""
                if user.role == .student {
                    timestampFieldName = "teacherLastActivityTimestamp"
                    isActiveFieldName = "teacherIsActive"
                }
                else if user.role == .teacher {
                    timestampFieldName = "studentLastActivityTimestamp"
                    isActiveFieldName = "studentIsActive"
                }
                if let timestamp = document.data()?[timestampFieldName] as? Timestamp {
                    if Int64(now.timeIntervalSince1970) - timestamp.seconds > 10 {
                        ref.setData([
                            isActiveFieldName: false
                        ], merge: true) { error in
                            if let error = error {
                                print("Error updating partners activity status: \(error)")
                            } else {
                                self.partnerPage = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    @Published var partnerPhoto: Image?
    func loadPartnerPhoto(session: FirestoreSession) {
        if let user = user {
            if user.role == .student, let teacherId = session.teacherId {
                ImageHelpers.loadImage(for: teacherId, in: "avatars") { img in
                    self.partnerPhoto = img
                }
            } else if user.role == .teacher, let studentId = session.studentId {
                ImageHelpers.loadImage(for: studentId, in: "avatars") { img in
                    self.partnerPhoto = img
                }
            }
        }
    }
}
