//
//  AuthNavigationView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/21/22.
//

import SwiftUI

struct AuthNavigationView: View {
    var body: some View {
        NavigationView {
            WelcomeView()
        }
        .navigationViewStyle(.stack)
    }
}

struct AuthNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthNavigationView()
    }
}
