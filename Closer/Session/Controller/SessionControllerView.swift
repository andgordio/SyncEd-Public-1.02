//
//  SessionController.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/3/22.
//

import SwiftUI

struct SessionControllerView: View {
    
    @StateObject var viewModel = SessionControllerViewModel()
    
    // TODO:
    // For SwiftUI 4: Refactor to expect only the sessionId. Pull lesson data from db.
    // Reason: streamlined implementation will work great with new navigation paths.
    let sessionId: String
    let lessonId: String
    let lessonName: String
    
    var body: some View {
        FullscreenBackground {
            ZStack {
                if let session = viewModel.session, !viewModel.isLoading {
                    TabView(selection: $viewModel.myPageIndex) {
                        ForEach(viewModel.sections, id: \.uid) { section in
                            SessionPageView(
                                section: section,
                                tasks: viewModel.tasks,
                                session: session,
                                sectionsCount: viewModel.sections.count
                            )
                            .tag(section.order)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        SessionToolbarView(
                            session: session,
                            myPageIndex: $viewModel.myPageIndex,
                            sections: viewModel.sections,
                            tasks: viewModel.tasks
                        )
                    }
                } else {
                    Text("Loading lesson")
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text(lessonName))
            .onAppear() {
                viewModel.loadViewModel(sessionId: sessionId, lessonId: lessonId)
            }
            .onDisappear(perform: {
                viewModel.deactivateMe()
                viewModel.stopPlayback()
            })
            .onChange(of: viewModel.myPageIndex) { newValue in
                viewModel.updateMyPage(to: newValue)
            }
            .onReceive(viewModel.timer) { _ in
                viewModel.reactivateMe()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SessionMenu(session: viewModel.session)
                }
            }
        }
    }
}

//struct SessionControllerView_Previews: PreviewProvider {
//    static var previews: some View {
//        SessionControllerView()
//    }
//}
