//
//  EnterNameViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI
import FirebaseFirestore

class EnterNameViewModel: ObservableObject {
    
    @Published var name = ""
    
    @Published var doShowChooseRoleView = false
    @Published var isLoading = false
    
    let validationEmptyString = "Please enter your name to proceed."
    let validationSomethingWrongString = "Something went wrong. Please, try again."
    @Published var validationError: String?
    
    public var db = Firestore.firestore()
    
    func initViewModel() {
        if let user = AuthManager.shared.firestoreUser {
            if !user.name.isEmpty {
                name = user.name
            }
        }
    }
    
    func sumbitHandler() {
        
        validationError = nil
        
        if name.isEmpty {
            validationError = validationEmptyString
            return
        }
        
        isLoading = true
        
        updateName() {
            self.doShowChooseRoleView = true
            self.isLoading = false
        }
    }
    
    func updateName(completion: @escaping () -> Void) {
        let authManager = AuthManager.shared
        if let user = authManager.firestoreUser {
            let docRef = db.collection("users").document(user.uid)
            docRef.setData([ "name": name ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    authManager.firestoreUser!.name = self.name
                }
                completion()
            }
        } else {
            // Rerport&Handle:
            // Something went terribly wrong: user entity shouldn’t be nil
            completion()
        }
    }
}
