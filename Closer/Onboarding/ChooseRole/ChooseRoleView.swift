//
//  ChooseRoleView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/24/22.
//

import SwiftUI

struct ChooseRoleView: View {
    
    @StateObject var viewModel = ChooseRoleViewModel()
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Choose your role")
                            .cardTitlePrimary()
                            .padding(.vertical, 0)
                        Text("A student can only invite a teacher to a lesson, and vice versa.")
                            .padding(.vertical, 10)
                    }
                    
                    RoleSelectionView(selectedRole: $viewModel.role)
                    
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
                    
                    NavigationLink(destination: UploadPhotoView(), isActive: $viewModel.doShowUploadPhotoView) { EmptyView() }
                    
                }
                .cardContainer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.initRole()
        }
    }
}

struct RoleSelectionView: View {
    
    @Binding var selectedRole: UserRole?
    
    var body: some View {
        HStack {
            ForEach(UserRole.allCases, id: \.self) { roleCase in
                Button(action: { selectedRole = roleCase }) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .foregroundColor(selectedRole == roleCase ? .accentColor : .gray)
                                .frame(width: 88, height: 88)
                                .opacity(selectedRole == roleCase ? 1 : 0.1)
                            Image(systemName: roleCase.systemIconName)
                                .font(.system(size: 34))
                                .foregroundColor(selectedRole == roleCase ? .white : .gray)
                                .opacity(selectedRole == roleCase ? 1 : 0.3)
                        }
                        .padding(.vertical, 24)
                        Text("I’m a \(roleCase.capitalizedName)")
                            .foregroundColor(selectedRole == roleCase ? .accentColor : .gray)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 16)
                    .background(selectedRole == roleCase ? Color("bg-with-tint") : Color("bg-secondary"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }
}

struct ChooseRoleView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseRoleView()
        }
    }
}
