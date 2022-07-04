//
//  EnterPhoneNumberViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/22/22.
//

import SwiftUI
import FirebaseAuth

class EnterPhoneNumberViewModel: ObservableObject {
    @Published var code = ""
    @Published var phone = ""
    
    let validationLengthString = "Your phone number should be 10 digits without spaces and dashes, like this: 1234567890"
    let validationRealNumberString = "The number doesn’t look right. Double check if it’s your phone number."
    let validationNetworkError = "Couldn’t verify your phone number. Please, check your internet connection — Wi-Fi or cellular — and try again."
    let validationTooManyRequests = "You’ve made too many attempts to log in within a short period of time. You’ll need to wait for at least 12 hours before you can try again."
    let validationUnknownError = "Something didn’t go as expected. Please, double check the phone number you entered and try again."
    @Published var validationError: String?
    
    @Published var isShowingEnterCodeView = false
    @Published var authVerificationID: String?
    
    @Published var isLoading = false
    
    
    func verifyHandler() {
        validationError = nil
        
        if phone.isEmpty || phone.count != 10 {
            validationError = validationLengthString
            return
        }
        
        isLoading = true
        
        AuthManager.shared.verifyPhoneNumber(code + phone) { [self] verificationID, error in
            
            if let error = error as NSError? {
//                if error.code == 17020 {
//                    self.validationError = self.validationNetworkError
//                } else if error.code == 17042 {
//                    self.validationError = self.validationRealNumberString
//                } else if error.code == 17010 {
//                    self.validationError = self.validationTooManyRequests
//                } else {
                    self.validationError = "Error code: \(error.code). Something didn’t go as expected. Please, double check the phone number you entered and try again."
//                }
                self.isLoading = false
                return
            }
            if let verificationID = verificationID {
                self.authVerificationID = verificationID
                self.isShowingEnterCodeView = true
            } else {
                self.validationError = self.validationRealNumberString
            }
            self.isLoading = false
        }
    }
    
    func onPhoneInputChange(code: String, phone: String) {
        self.code = code
        self.phone = phone
    }
}
