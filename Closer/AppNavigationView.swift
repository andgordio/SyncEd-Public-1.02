//
//  MainTabView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/21/22.
//

import SwiftUI

struct AppNavigationView: View {
    var body: some View {
        NavigationView {
            HomeView()
        }
        .navigationViewStyle(.stack)
    }
}

struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AppNavigationView()
    }
}
