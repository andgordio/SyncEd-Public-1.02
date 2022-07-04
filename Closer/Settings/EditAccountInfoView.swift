//
//  EditAccountInfoView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI

struct EditAccountInfoView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = EditAccountInfoViewModel()
    
    enum Field: Hashable {
        case name
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            FullscreenBackground {
                ScrollView {
                    VStack(spacing: 32) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Edit profile")
                                .cardTitlePrimary()
                                .padding(.vertical, 0)
                        }
                        VStack(alignment: .leading) {
                            Text("Name:")
                                .foregroundColor(.secondary)
                            TextField("", text: $viewModel.name)
                                .focused($focusedField, equals: .name)
                                .frame(maxWidth: .infinity)
                                .formControlPrimary()
                        }
                        VStack(alignment: .leading) {
                            Text("Role:")
                                .foregroundColor(.secondary)
                            RoleSelectionView(selectedRole: $viewModel.role)
                        }
                    }
                    .padding(.bottom, 16)
                    .cardContainer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save() {
                            dismiss()
                        }
                    } label: {
                        Text("Save")
                    }
                }
            }
            .onAppear {
                viewModel.initViewModel()
            }
        }
    }
}

struct EditAccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountInfoView()
    }
}
