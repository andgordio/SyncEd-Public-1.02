//
//  InviteView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI

struct InviteView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = InviteViewModel()
    
    var lessonId: String
    var session: FirestoreSession?
    var doAllowSkip: Bool
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    InviteByPhoneView(
                        lessonId: lessonId,
                        session: session,
                        dismiss: { dismiss() }
                    )
                } header: {
                    Text("Invite by phone")
                }
                
                Section {
                    if !viewModel.isLoadingRecent {
                        if !viewModel.recentPartners.isEmpty {
                            ForEach(viewModel.recentPartners, id: \.uid) { recentPartner in
                                InviteRowView(
                                    user: recentPartner,
                                    session: session,
                                    lessonId: lessonId,
                                    dismiss: { dismiss() }
                                )
                            }
                        } else {
                            Text("Users you invite to sessions will appear here")
                        }
                    } else {
                        Text("Loading...")
                    }
                } header: {
                    Text("Recent")
                }
            }
            .onAppear {
                viewModel.loadRecentUsers()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Invite partner"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if doAllowSkip {
                        Button {
                            viewModel.createSession(for: lessonId) { _ in
                                dismiss()
                            }
                        } label: {
                            Text("Skip")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    
                }
            }
        }
    }
}
