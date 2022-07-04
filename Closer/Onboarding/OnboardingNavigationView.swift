//
//  OnboardingNavigationView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/21/22.
//

import SwiftUI

struct OnboardingNavigationView: View {
    
    var body: some View {
        NavigationView {
            EnterNameView()
        }
        .navigationViewStyle(.stack)
    }
}

struct OnboardingNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingNavigationView()
    }
}
