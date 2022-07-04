//
//  InvitationsView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/13/22.
//

import SwiftUI

struct InvitationsView: View {
    
    @StateObject var viewModel = InvitationsViewModel()
    
    var areVisibleInvitationsPresent: Bool {
        if viewModel.invitations.count == 0 {
            return false
        }
        else {
            return viewModel.invitations.firstIndex(where: { !$0.isHidden }) != nil
        }
    }

    var body: some View {
        VStack {
            ForEach(viewModel.invitations, id: \.sessionId) { invitation in
                NavigationLink {
                    LessonView(lesson: invitation.lesson)
                } label: {
                    InvitationRowView(invitation: invitation)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 24)
        .clipShape(Rectangle())
        .frame(
            maxWidth: areVisibleInvitationsPresent ? .infinity : 0,
            maxHeight: areVisibleInvitationsPresent ? .infinity : 0
        )
        .onAppear {
            viewModel.loadInvitations()
        }
    }
}

struct InvitationsView_Previews: PreviewProvider {
    static var previews: some View {
        InvitationsView()
    }
}
