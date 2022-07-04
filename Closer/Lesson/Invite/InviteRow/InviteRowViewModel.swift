//
//  InviteRowViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage

class InviteRowViewModel: ObservableObject {
    
    public var db = Firestore.firestore()
    
    @Published var isLoadingModel = true
    @Published var photo: Image?
    @Published var isInvited: Bool = false
    @Published var isSelf: Bool = false
    @Published var isMyRole: Bool = false
    
    func initViewModel(with user: FirestoreUser, session: FirestoreSession?) {
        if let session = session {
            var partnerId: String?
            if user.role == .student {
                partnerId = session.studentId
            } else if user.role == .teacher {
                partnerId = session.teacherId
            }
            if let partnerId = partnerId {
                isInvited = partnerId == user.uid
            }
        }
        if let me = AuthManager.shared.firestoreUser {
            isSelf = me.uid == user.uid
            isMyRole = me.role == user.role
        } else {
            // Report&Handler bad error
        }
        let pathReference = Storage.storage().reference(withPath: "avatars/\(user.uid).jpg")
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error \(error.localizedDescription)")
            } else {
                let loadedImage = UIImage(data: data!)
                if let loadedImage = loadedImage {
                    self.photo = Image(uiImage: loadedImage)
                }
            }
        }
        isLoadingModel = false
    }
    
    func invite(user: FirestoreUser, session: FirestoreSession?, lessonId: String, completion: @escaping () -> Void) {
        
        // Todo:
        // Block all actions in InviteView while processing.
        if let session = session {
            createPartnerInFirebase(partner: user, sessionId: session.uid, completion: completion)
        } else {
            createSession(in: lessonId) { sessionId in
                self.createPartnerInFirebase(partner: user, sessionId: sessionId, completion: completion)
            }
        }
        
    }
    
    func createPartnerInFirebase(partner: FirestoreUser, sessionId: String, completion: @escaping () -> Void) {
        
        var partnerUidFieldName: String = ""
        var partnerNameFieldName: String = ""
        var partnerJoinedFieldName: String = ""
        
        if let user = AuthManager.shared.firestoreUser, let partnerRole = partner.role {
            if user.role == .student {
                partnerUidFieldName = "teacherId"
                partnerNameFieldName = "teacherName"
                partnerJoinedFieldName = "teacherJoined"
            } else if user.role == .teacher {
                partnerUidFieldName = "studentId"
                partnerNameFieldName = "studentName"
                partnerJoinedFieldName = "studentJoined"
            }
            
            db.collection("sessions").document(sessionId).setData(
                [
                    partnerUidFieldName: partner.uid,
                    partnerNameFieldName: partner.name,
                    partnerJoinedFieldName: false
                ],
                merge: true
            ) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                }
                self.db.collection("users").document(user.uid).collection("recentlyInvited")
                    .document(partner.uid).setData(
                        [
                            "name": partner.name,
                            "role": partnerRole.rawValue,
                        ],
                        merge: true
                    ) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        }
                        completion()
                    }
            }
        } else {
            // Report bad error
            completion()
        }
    }
    
    
    // TODO: merge with LessonViewModel’s createSession method
    func createSession(in lessonId: String, completion: @escaping (String) -> Void) {
        
        guard let firestoreUser = AuthManager.shared.firestoreUser else {
            print("No user found. Authentication error")
            return
        }
        
        var data: [String: Any] = [
            "dateCreated": FieldValue.serverTimestamp(),
            "isCompleted": false,
            "studentStarted": false,
            "teacherStarted": false,
            "lessonId": lessonId
        ]
        let role = firestoreUser.role
        if role == .student {
            data["studentId"] = firestoreUser.uid
            data["studentName"] = firestoreUser.name
            data["studentJoined"] = true
            data["teacherJoined"] = false
            data["teacherId"] = ""
            data["teacherName"] = ""
        } else if role == .teacher {
            data["teacherId"] = firestoreUser.uid
            data["teacherName"] = firestoreUser.name
            data["teacherJoined"] = true
            data["studentJoined"] = false
            data["studentId"] = ""
            data["studentName"] = ""
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("sessions").addDocument(data: data) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                completion(ref!.documentID)
            }
        }
    }
}
