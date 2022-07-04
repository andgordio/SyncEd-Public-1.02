//
//  InviteViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI
import FirebaseFirestore

class InviteViewModel: ObservableObject {
    
    public var db = Firestore.firestore()
    
    @Published var isLoadingRecent: Bool = false
    @Published var recentPartners: [FirestoreUser] = []
    
    func loadRecentUsers() {
        
        isLoadingRecent = true
        var usersToLoad = 0
        
        if let user = AuthManager.shared.firestoreUser {
            db
                .collection("users")
                .document(user.uid)
                .collection("recentlyInvited")
                .getDocuments { snapshot, err in
                    if let err = err {
                        print("Error getting documents: \(err.localizedDescription)")
                        self.isLoadingRecent = false
                    } else {
                        guard let snapshot = snapshot else {
                            print("Error fetching snapshots: \(err?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        if snapshot.documents.isEmpty {
                            self.isLoadingRecent = false
                        } else {
                            usersToLoad = snapshot.documents.count
                            snapshot.documents.forEach { document in
                                let partner = FirestoreUser(
                                    // ~ Todo ~
                                    // Most of this data doesn’t exist in collection("recentlyInvited").
                                    // Maybe a different model will be appropriate here?
                                    uid: document.documentID,
                                    phoneNumber: document.data()["phoneNumber"] as? String ?? "",
                                    role: UserRole(rawValue: document.data()["role"] as? String ?? ""),
                                    name: document.data()["name"] as? String ?? "",
                                    didCompleteOnboarding: document.data()["didCompleteOnboarding"] as? Bool ?? false
                                )
                                self.recentPartners.append(partner)
                                usersToLoad -= 1
                                if usersToLoad == 0 {
                                    self.isLoadingRecent = false
                                }
                            }
                        }
                    }
                }
        }
    }
    
    public func createPartnerInFirebase(
        partner: Partner,
        session: FirestoreSession,
        completion: @escaping () -> Void
    ) {
        var partnerUidFieldName: String = ""
        var partnerNameFieldName: String = ""
        var partnerJoinedFieldName: String = ""
        
        if let user = AuthManager.shared.firestoreUser {
            if user.role == .student {
                partnerUidFieldName = "teacherId"
                partnerNameFieldName = "teacherName"
                partnerJoinedFieldName = "teacherJoined"
            } else if user.role == .teacher {
                partnerUidFieldName = "studentId"
                partnerNameFieldName = "studentName"
                partnerJoinedFieldName = "studentJoined"
            }
            
            db.collection("sessions").document(session.uid).setData(
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
                            "role": partner.role.rawValue,
                        ],
                        merge: true
                    ) { err in
                        // Report&Handle
                    }
                completion()
            }
        }
    }
    
    // Note:
    // This very same function exists in InviteRowViewModel.
    // Avoid repeating.
    //
    func createSession(for lessonId: String, completion: @escaping (String) -> Void) {
        
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
