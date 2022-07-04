//
//  EnterNameView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/21/22.
//

import SwiftUI

struct EnterNameView: View {
    
    @StateObject var viewModel = EnterNameViewModel()
    
    enum Field: Hashable {
        case name
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("What’s your name?")
                            .cardTitlePrimary()
                            .padding(.vertical, 0)
                        Text("Introduce yourself to help others recognize you when they invite you to a lesson.")
                            .padding(.vertical, 10)
                    }
                    
                    TextField("", text: $viewModel.name)
                        .focused($focusedField, equals: .name)
                        .frame(maxWidth: .infinity)
                        .formControlPrimary()
                    
                    if let validationError = viewModel.validationError {
                        Text(validationError)
                            .formTextValidation()
                    }
                    
                    Button(action: viewModel.sumbitHandler) {
                        ButtonTextPrimary(
                            text: "Continue",
                            isLoading: viewModel.isLoading
                        )
                        .padding(.top, 8)
                    }
                    .disabled(viewModel.isLoading)
                    
                    NavigationLink(destination: ChooseRoleView(), isActive: $viewModel.doShowChooseRoleView) { EmptyView() }
                }
                .cardContainer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.initViewModel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                focusedField = .name
            }
        }
    }
}

struct EnterNameView_Previews: PreviewProvider {
    static var previews: some View {
        EnterNameView()
    }
}
