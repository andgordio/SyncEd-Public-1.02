//
//  LessonsView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/20/22.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                InvitationsView()
                RecentView()
                ForEach(LessonLevel.allCases, id: \.self) { level in
                    LessonsSectionView(level: level)
                }
            }
            .navigationTitle(Text("SyncEd"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: SettingsView(), label: {
                        Label("Settings", systemImage: "gear")
                    })
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}
