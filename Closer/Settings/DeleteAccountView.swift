//
//  DeleteAccountView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI

struct DeleteAccountView: View {
    
    @StateObject var viewModel = DeleteAccountViewModel()
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                VStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Delete account")
                            .cardTitlePrimary()
                            .padding(.vertical, 0)
                        Text("This cannot be undone. Once you delete your account all information linked to your account — including your personal information and session history — is deleted and cannot be restored.")
                            .padding(.vertical, 10)
                        Text("If you have any feedback you’d like to share before you go enter it below — it’s sent to our team anonymously:")
                            .padding(.vertical, 10)
                    }
                    TextEditor(text: $viewModel.feedbackInput)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .frame(minHeight: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.tertiary)
                        )
                        .opacity(viewModel.isLoading ? 0.2 : 1)
                    Button(action: viewModel.deleteAccount) {
                        ButtonTextPrimary(
                            text: "Delete account",
                            isLoading: viewModel.isLoading,
                            isDangerous: true
                        )
                        .padding(.top, 8)
                    }
                    .disabled(viewModel.isLoading)
                }
                .cardContainer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}
