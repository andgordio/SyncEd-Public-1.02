//
//  LessonSessionRow.swift
//  Playgrounds
//
//  Created by Andriy Gordiyenko on 6/8/22.
//

import SwiftUI

struct LessonSessionRowView: View {
    
    @StateObject var viewModel = LessonSessionRowViewModel()
    
    let lesson: Lesson
    let session: FirestoreSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationLink(
                destination: SessionControllerView(sessionId: session.uid, lessonId: lesson.uid, lessonName: lesson.name)
            ) {
                HStack(spacing: 20) {
                    if let partner = viewModel.partner, let photo = partner.photo {
                        photo
                            .resizable()
                            .scaledToFill()
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .frame(width: 56, height: 56)
                            .foregroundColor(Color("gray-tertiary"))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.partner == nil ? "No partner" : viewModel.partner!.name)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        ZStack {
                            if let partner = viewModel.partner {
                                Text(partner.joined ? "Joined" : "Waiting for response")
                            } else {
                                Text("Tap and hold to add")
                            }
                        }
                        .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .foregroundColor(Color("gray-tertiary"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .background()
            Divider().padding(.leading, 24 + 56 + 24)
        }
        .contextMenu {
            Button {
                viewModel.doShowIviteSheet = true
            } label: {
                Label(viewModel.partner != nil ? "Change partner" : "Invite", systemImage: "person.badge.plus")
            }
            if viewModel.partner != nil {
                Button {
                    viewModel.doShowRemovePartnerConfirmation = true
                } label: {
                    Label("Remove partner", systemImage: "person.badge.minus")
                }
            }
            Button {
                viewModel.doShowQuitConfirmation = true
            } label: {
                Label("Quit session", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .confirmationDialog(
            "Are you sure you want to quit the session? ",
            isPresented: $viewModel.doShowQuitConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                viewModel.quitSession()
            } label: {
                Text("Quit session")
            }
        }
        .confirmationDialog(
            "Are you sure you want to remove your partner from the session? ",
            isPresented: $viewModel.doShowRemovePartnerConfirmation,
            titleVisibility: .visible
        ) {
            Button(role: .destructive, action: viewModel.removePartner) {
                Text("Remove partner")
            }
        }
        .sheet(
            isPresented: $viewModel.doShowIviteSheet
        ) {
            InviteView(
                lessonId: lesson.uid,
                session: session,
                doAllowSkip: false
            )
        }
        .onAppear {
            viewModel.loadViewModel(for: session)
        }
        .onChange(of: session) { newValue in
            viewModel.loadViewModel(for: newValue)
        }
    }
}
