//
//  SessionToolbarView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/15/22.
//

import SwiftUI

struct SessionToolbarView: View {
    
    @StateObject var viewModel = SessionToolbarViewModel()
    
    var session: FirestoreSession
    @Binding var myPageIndex: Int
    var sections: [LessonSection]
    var tasks: [LessonTask]
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 4) {
                ForEach(sections, id: \.uid) { section in
                    SessionToolbarTabView(
                        section: section,
                        myPageIndex: myPageIndex,
                        partnerPageIndex: viewModel.partnerPage,
                        partnerPhoto: viewModel.partnerPhoto,
                        tasks: tasks
                    ) {
                        myPageIndex = section.order
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .padding(.bottom, 10)
            .background()
        }
        .onAppear {
            viewModel.loadPartnerPhoto(session: session)
            viewModel.initWatchPartnerPage(session: session)
        }
        .onReceive(viewModel.timer) { _ in
            viewModel.checkPartnerIdleTime(session: session)
        }
    }
}
