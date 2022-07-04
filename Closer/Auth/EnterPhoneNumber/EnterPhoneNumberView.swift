//
//  EnterPhoneNumberView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/20/22.
//

import SwiftUI

struct EnterPhoneNumberView: View {
    
    @StateObject var viewModel = EnterPhoneNumberViewModel()
    
    @FocusState var isPhoneFieldFocused
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Enter your phone number")
                            .cardTitlePrimary()
                            .padding(.vertical, 0)
                        Text("It will be linked to your personal profile and will allow others to find you in the app.")
                            .padding(.vertical, 10)
                    }
                    
                    PhoneNumberView(
                        isPhoneFieldFocused: $isPhoneFieldFocused,
                        onInputValueChange: viewModel.onPhoneInputChange
                    )
                    
                    if let validationError = viewModel.validationError {
                        Text(validationError)
                            .formTextValidation()
                    }
                    
                    Button(action: viewModel.verifyHandler) {
                        ButtonTextPrimary(
                            text: "Continue",
                            isLoading: viewModel.isLoading
                        )
                        .padding(.top, 8)
                    }
                    .disabled(viewModel.isLoading)
                    
                    
                    NavigationLink(
                        destination: EnterSMSCodeView(
                            authVerificationID: viewModel.authVerificationID
                        ),
                        isActive: $viewModel.isShowingEnterCodeView
                    ) {
                        EmptyView()
                    }
                }
                .cardContainer()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("We’ll send you an SMS. Standard cellular provider charges may be applied.")
                    Text("Phone number that you provide for authentication will be sent and stored by Google to improve their spam and abuse prevention across Google services.")
                    Link("Full Terms of Use", destination: URL(string: "https://www.andgordy.com/synced/terms")!)
                        .foregroundColor(.blue)
                }
                .font(.footnote)
                .padding(.top, 12)
                .padding(.horizontal)
                .padding(.horizontal, 8)
                .foregroundColor(.gray)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                isPhoneFieldFocused  = true
            }
        }
    }
}


struct EnterPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EnterPhoneNumberView()
        }
    }
}

