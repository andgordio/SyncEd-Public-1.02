//
//  SessionMenu.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/16/22.
//

import SwiftUI

struct SessionMenu: View {
    
    // Note:
    // This is uncomfortably similar to LessonSessionRowView, except for this one’s Menu, and the other one is .contextMenu
    // This one doesn’t even have its own view model, it resuses the Row‘s one.
    // Todo: find a way to merge the two components.
    
    @StateObject var viewModel = LessonSessionRowViewModel()
    
    let session: FirestoreSession?
    
    var body: some View {
        Menu {
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
        } label: {
            Label("Session menu", systemImage: "ellipsis")
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
            Button(role: .destructive) {
                viewModel.removePartner()
            } label: {
                Text("Remove partner")
            }
        }
        .sheet(
            isPresented: $viewModel.doShowIviteSheet
        ) {
            if let session = session {
                InviteView(
                    lessonId: session.lessonId,
                    session: session,
                    doAllowSkip: false
                )
            }
        }
        .onAppear {
            viewModel.loadViewModel(for: session)
        }
        .onChange(of: session) { newValue in
            viewModel.loadViewModel(for: newValue)
        }
    }
}
