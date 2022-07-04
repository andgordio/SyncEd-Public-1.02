//
//  DeleteAccountViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class DeleteAccountViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var feedbackInput: String = ""
    
    public var db = Firestore.firestore()
    
    func deleteAccount() {
        isLoading = true
        if !feedbackInput.isEmpty {
            submitFeedback()
        }
        if let user = Auth.auth().currentUser {
            deleteUser(user)
        }
    }
    
    private func submitFeedback() {
        db.collection("feedback").addDocument(data: [
            "dateCreated": FieldValue.serverTimestamp(),
            "body": feedbackInput,
            "type": "deleteAccount"
        ], completion: { error in
            if let error = error {
                print("Error when submitting feedback: \(error)")
                return
            }
        })
    }
    
    private func deleteUser(_ user: User) {
        db.collection("users").document(user.uid).delete() { firestoreError in
            if let firestoreError = firestoreError {
                print("Error when deleting account: \(firestoreError)")
            } else {
                user.delete { authError in
                    if let authError = authError {
                        print("Error when deleting account: \(authError)")
                      }
                }
            }
        }
    }
}
