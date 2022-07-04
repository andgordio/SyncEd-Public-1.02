//
//  UploadPhotoViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/22/22.
//

import SwiftUI

class UploadPhotoViewModel: ObservableObject {
    
    @Published var isFinishingOnboarding = false
    @Published var isLoadingPhoto = false
    
    func finishOnboardingHandler() {
        isFinishingOnboarding = true
        AuthManager.shared.finishOnboarding() {
            self.isFinishingOnboarding = false
        }
    }
    
}
