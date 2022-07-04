//
//  SettingsViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var doShowEditView = false
    
    func signOut() {
        isLoading = true
        AuthManager.shared.signOut {
            isLoading = false
        }
    }
}
