//
//  RecentView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI

struct RecentView: View {
    
    @StateObject var viewModel = RecentViewModel()
    
    var body: some View {
        VStack(spacing: 18) {
            if viewModel.recent.count > 0 {
                HStack {
                    Text("Recent")
                    Spacer()
                }
                .font(.system(size: 22, weight: .semibold))
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.recent, id: \.sessionId) { recent in
                            NavigationLink {
                                SessionControllerView(sessionId: recent.sessionId, lessonId: recent.lesson.uid, lessonName: recent.lesson.name)
                            } label: {
                                RecentCardView(recent: recent)
                            }
                        }
                    }
                    .padding(.leading)
                    .padding(.trailing)
                }
            } else {
                EmptyView()
            }
        }
        .padding(.top, viewModel.recent.count > 0 ? 32 : 0)
        .onAppear() {
            viewModel.loadRecent()
        }
    }
}

struct RecentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentView()
    }
}
