//
//  InviteByPhoneViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI
import FirebaseFirestore

class InviteByPhoneViewModel: ObservableObject {
    
    public var db = Firestore.firestore()
    
    @Published var userFound: FirestoreUser?
    
    @Published var isLoading: Bool = false
    @Published var code: String = ""
    @Published var phone: String = ""
    
    func onPhoneInputChange(code: String, phone: String) {
        self.code = code
        self.phone = phone
        self.userFound = nil
        
        if phone.count == 10 {
            
            isLoading = true
            let query = db.collection("users").whereField("phoneNumber", isEqualTo: code+phone)
            query.getDocuments { snapshot, err in
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
                    }
                    snapshot.documents.forEach { document in
                        self.userFound = FirestoreUser(
                            uid: document.documentID,
                            phoneNumber: document.data()["phoneNumber"] as? String ?? "",
                            role: UserRole(rawValue: document.data()["role"] as? String ?? ""),
                            name: document.data()["name"] as? String ?? "",
                            didCompleteOnboarding: document.data()["didCompleteOnboarding"] as? Bool ?? false
                        )
                    }
                }
            }
        }
    }
    
}
