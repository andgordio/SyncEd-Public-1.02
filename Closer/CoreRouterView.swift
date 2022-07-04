//
//  AuthOrAppView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/20/22.
//

import SwiftUI
import FirebaseAuth

struct CoreRouter: View {
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        if !authManager.didCheckAuthUser {
            LoadingView()
        } else {
            if authManager.user == nil {
                AuthNavigationView()
            } else {
                if let firestoreUser = authManager.firestoreUser {
                    if firestoreUser.didCompleteOnboarding {
                        AppNavigationView()
                    }
                    else {
                        OnboardingNavigationView()
                    }
                }
                else {
                    LoadingView()
                }
            }
        }
    }
}

struct CoreRouter_Previews: PreviewProvider {
    static var previews: some View {
        CoreRouter()
    }
}
