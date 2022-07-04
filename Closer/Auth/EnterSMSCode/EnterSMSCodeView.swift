//
//  EnterSMSCodeView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/20/22.
//

import SwiftUI

struct EnterSMSCodeView: View {
    
    @StateObject var viewModel = EnterSMSCodeViewModel()
    
    var authVerificationID: String?
    
    enum Field: Hashable {
        case code
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Enter code")
                        .cardTitlePrimary()
                        .padding(.vertical, 0)
                    Text("We just sent you an sms with a code. Copy it from the Messages app or wait till it appears above your keyboard.")
                        .padding(.vertical, 10)
                }
                
                TextField("123456", text: $viewModel.code)
                    .keyboardType(.phonePad)
                    .focused($focusedField, equals: .code)
                    .frame(maxWidth: .infinity)
                    .formControlPrimary()
                    .onChange(of: viewModel.code) { newValue in
                        if newValue.count == 6 {
                            if let authVerificationID = authVerificationID {
                                viewModel.loginHandler(authVerificationID)
                            }
                        }
                    }
                
                if let validationError = viewModel.validationError {
                    Text(validationError)
                        .formTextValidation()
                }
                
                Button {
                    if let authVerificationID = authVerificationID {
                        viewModel.loginHandler(authVerificationID)
                    }
                } label: {
                    ButtonTextPrimary(
                        text: "Log in",
                        isLoading: viewModel.isLoading
                    )
                    .padding(.top, 8)
                }
                .disabled(viewModel.isLoading)
            }
            .cardContainer()
        }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                focusedField = .code
            }
        }
    }
}

struct EnterSMSCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterSMSCodeView(authVerificationID: "test")
    }
}
