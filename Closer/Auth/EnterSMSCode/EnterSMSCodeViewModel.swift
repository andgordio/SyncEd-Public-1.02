//
//  EnterSMSCodeViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/22/22.
//

import SwiftUI

class EnterSMSCodeViewModel: ObservableObject {
    
    let validationEmptyString = "Please, enter the code you received via sms."
    let validationInvalidCodeString = "The code doesn’t look right. Make sure you enter the code from the sms."
    @Published var validationError: String?
    
    @Published var code = ""
    @Published var isLoading = false
    
    func loginHandler(_ authVerificationID: String) {
        
        validationError = nil
        
        if code.isEmpty {
            validationError = validationEmptyString
            return
        }
        
        isLoading = true
    
        AuthManager.shared.signIn(authVerificationID: authVerificationID, code: code) { error in
            self.isLoading = false
            if let _ = error {
                self.validationError = self.validationInvalidCodeString
                return
            }
        }
    }
}
