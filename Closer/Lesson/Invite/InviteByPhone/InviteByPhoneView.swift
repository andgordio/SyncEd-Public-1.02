//
//  InviteByPhoneView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI

struct InviteByPhoneView: View {
    
    @StateObject var viewModel = InviteByPhoneViewModel()
    
    var lessonId: String
    var session: FirestoreSession?
    
    // ~ Note ~
    // I can’t call environments \.dismiss here directly because this view
    // is inside NavigationView, which is a different environment.
    var dismiss: () -> Void
    
    var inviteHelperText: String {
        if viewModel.isLoading {
            return Strings.loading
        }
        else if (!viewModel.isLoading && viewModel.userFound != nil) {
            return viewModel.userFound!.name
        }
        else if viewModel.phone.count != 10 {
            return Strings.resultsWillAppear
        }
        else {
            return Strings.userNotFound
        }
    }
    
    struct Strings {
        static var loading = "Loading..."
        static var resultsWillAppear = "Results will appear once you enter 10 digits of the phone number"
        static var userNotFound = "Couldn’t find a user with this name"
    }
    
    @FocusState var isPhoneFieldFocused
    
    var body: some View {
        VStack(alignment: .leading) {
            PhoneNumberView(
                isPhoneFieldFocused: $isPhoneFieldFocused,
                onInputValueChange: viewModel.onPhoneInputChange
            )
            if isPhoneFieldFocused && viewModel.userFound == nil {
                Text(inviteHelperText)
                    .padding(.top, 4)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            if let userFound = viewModel.userFound {
                InviteRowView(
                    user: userFound,
                    session: session,
                    lessonId: lessonId,
                    dismiss: dismiss
                )
                .padding(.top, 8)
            }
        }
        .padding(.vertical)
    }
}
