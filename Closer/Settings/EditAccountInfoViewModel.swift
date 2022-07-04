//
//  EditAccountInfoViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI
import FirebaseFirestore

class EditAccountInfoViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var role: UserRole?
    
    public var db = Firestore.firestore()
    
    func initViewModel() {
        if let user = AuthManager.shared.firestoreUser {
            self.name = user.name
            self.role = user.role
        }
    }
    
    func save(completion: @escaping () -> Void) {
        if let user = AuthManager.shared.firestoreUser, let role = role {
            db
                .collection("users")
                .document(user.uid)
                .setData([
                    "name": name,
                    "role": role.rawValue
                ], merge: true) { err in
                    if let err = err {
                        print("Error updating profile: \(err)")
                    }
                    AuthManager.shared.firestoreUser?.name = self.name
                    AuthManager.shared.firestoreUser?.role = self.role
                    completion()
                }
        }
    }
}
