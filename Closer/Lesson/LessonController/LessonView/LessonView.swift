//
//  LessonView2.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI

struct LessonView: View {
    
    @StateObject var viewModel = LessonViewModel()
    var lesson: Lesson
    
    let paddingFactor: CGFloat = 0.06
    let cornerRadius: CGFloat = 10
    
    var invitations: [FirestoreSession] {
        if let user = AuthManager.shared.firestoreUser {
            if user.role == .student {
                return viewModel.sessions.filter({ !$0.studentJoined })
            } else {
                return viewModel.sessions.filter({ !$0.teacherJoined })
            }
        } else {
            return []
        }
    }
    
    var sessions: [FirestoreSession] {
        if let user = AuthManager.shared.firestoreUser {
            if user.role == .student {
                return viewModel.sessions.filter({ $0.studentJoined })
            } else {
                return viewModel.sessions.filter({ $0.teacherJoined })
            }
        } else {
            return []
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                
                ZStack {
                    if let cover = viewModel.cover {
                        cover
                            .resizable()
                            .scaledToFill()
                            .lessonCoverImageFrame(geometry, paddingFactor)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                            .lessonCoverImagePadding(geometry, paddingFactor)
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundColor(Color("bg-tertiary"))
                            .lessonCoverImageFrame(geometry, paddingFactor)
                            .lessonCoverImagePadding(geometry, paddingFactor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(lesson.name)
                        .font(.system(size: 32, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        LessonLevelBadgeView(lesson.level)
                        // # Note
                        // - Add meta data here when available
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                    Text(lesson.description)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background()
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .padding(.horizontal, geometry.size.width * paddingFactor)
                
                if invitations.count == 1 {
                    LessonInvitationCardView(
                        session: invitations[0],
                        cornerRadius: cornerRadius
                    )
                } else if invitations.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(invitations, id: \.uid) { session in
                                LessonInvitationCardView(
                                    session: session,
                                    cornerRadius: cornerRadius
                                )
                            }
                        }
                        .padding(.horizontal, geometry.size.width * paddingFactor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(sessions, id: \.uid) { session in
                        LessonSessionRowView(lesson: lesson, session: session)
                    }
                    LessonSessionAddView(onTapGesture:  {
                        viewModel.sessionForInvite = nil
                        viewModel.doShowIviteSheet = true
                    })
                }
                .background()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, geometry.size.width * paddingFactor)
                .padding(.top, 24)
                .sheet(isPresented: $viewModel.doShowIviteSheet) {
                    InviteView(
                        lessonId: lesson.uid,
                        session: viewModel.sessionForInvite,
                        doAllowSkip: true
                    )
                }
                
                Spacer().padding(.bottom, 100)
            }
            .background(Color("bg-secondary"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                viewModel.loadSessions(for: lesson)
            }
        }
    }
    
    struct LoadingSessions: View {
        var body: some View {
            Text("Loading sessions...")
        }
    }
}


struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView(
            lesson: Lesson(
                uid: "123", name: "Sample lesson",
                description: "Sample description",
                level: .beginner
            )
        )
        .previewDevice("iPhone 13 Pro Max")
    }
}
