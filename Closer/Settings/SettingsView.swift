//
//  SettingsView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/20/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                VStack {
                    
                    VStack(spacing: 16) {
                        
                        ProfilePhotoManager(isLoading: $viewModel.isLoading)
                        
                        VStack(spacing: 6) {
                            Text(AuthManager.shared.firestoreUser?.name ?? "Noname")
                                .font(.system(size: 24, weight: .semibold))
                                .frame(maxWidth: .infinity)
                            Text(AuthManager.shared.firestoreUser?.role?.capitalizedName ?? "Unknown role")
                                .font(.system(size: 17))
                                .foregroundColor(.secondary)
                        }
                        
                        Button {
                            viewModel.doShowEditView = true
                        } label: {
                            Text("Edit")
                        }
                        .padding(.bottom, 12)
                        .sheet(isPresented: $viewModel.doShowEditView) {
                            EditAccountInfoView()
                        }
                        
                    }
                    .cardContainer()
                    
                    Button(action: viewModel.signOut) {
                        Text("Log out")
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 64)
                    
                    NavigationLink {
                        DeleteAccountView()
                    } label: {
                        Text("Delete account")
                            .foregroundColor(.red)
                    }
                    .padding(.top, 32)
                    .disabled(viewModel.isLoading)
                    
                }
            }
        }
        .navigationTitle(Text("Settings"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
