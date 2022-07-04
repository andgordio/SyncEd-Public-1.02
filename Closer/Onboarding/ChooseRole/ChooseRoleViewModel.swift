//
//  ChooseRoleViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/22/22.
//

import SwiftUI

class ChooseRoleViewModel: ObservableObject {
    
    @Published var doShowUploadPhotoView = false
    @Published var isLoading = false
    
    let validationEmptyString = "Please choose your role to proceed."
    @Published var validationError: String?
    
    @Published var role: UserRole? = nil
    
    func initRole() {
        if let firestoreUser = AuthManager.shared.firestoreUser {
            if firestoreUser.role != nil {
                role = firestoreUser.role
            }
        }
    }
    
    func sumbitHandler() {

        validationError = nil
        
        if let role = role {
            isLoading = true
            AuthManager.shared.updateRole(role) {
                self.doShowUploadPhotoView = true
                self.isLoading = false
            }
        } else {
            validationError = validationEmptyString
            return
        }
    }
    
}
