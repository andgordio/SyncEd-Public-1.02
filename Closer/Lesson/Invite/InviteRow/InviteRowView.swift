//
//  InviteRowView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI

struct InviteRowView: View {
    
    @StateObject var viewModel = InviteRowViewModel()
    
    let user: FirestoreUser
    let session: FirestoreSession?
    let lessonId: String
    let dismiss: () -> Void
    
    var previewDiameter: CGFloat = 48
    
    var body: some View {
        HStack {
            if let photo = viewModel.photo {
                Thumbnail(photo, diameter: previewDiameter)
            } else {
                ThumbnailPlaceholder(diameter: previewDiameter)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(user.name)
                if viewModel.isSelf {
                    Subtitle(Strings.itsYou)
                } else if viewModel.isMyRole {
                    Subtitle(user.role == .student ? Strings.anotherStudent : Strings.anotherTeacher)
                }
                
            }
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if viewModel.isInvited {
                Text(Strings.invited)
                    .padding(.horizontal, 8)
                    .foregroundColor(.gray)
            } else if viewModel.isSelf || viewModel.isMyRole {
                EmptyView()
            } else {
                Button {
                    viewModel.invite(user: user, session: session, lessonId: lessonId) {
                        dismiss()
                    }
                } label: {
                    Text(Strings.invite)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
        .onAppear() {
            viewModel.initViewModel(
                with: user,
                session: session
            )
        }
    }
    
    struct Subtitle: View {
        var text: String
        init (_ text: String) { self.text = text }
        var body: some View {
            Text(text)
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.top, 3)
        }
    }
    
    struct Strings {
        static var itsYou = "Can’t invite yourself"
        static var anotherStudent = "Can’t invite another student"
        static var anotherTeacher = "Can’t invite another teacher"
        static var invite = "Invite"
        static var invited = "Invited"
    }
}
