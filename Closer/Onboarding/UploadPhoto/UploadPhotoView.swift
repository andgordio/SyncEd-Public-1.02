//
//  UploadPhotoView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/21/22.
//

import SwiftUI
import FirebaseStorage

struct UploadPhotoView: View {
    
    @StateObject var viewModel = UploadPhotoViewModel()
    
    var body: some View {
        FullscreenBackground {
            ScrollView {
                VStack {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Add your photo")
                            .cardTitlePrimary()
                            .padding(.vertical, 0)
                        Text("SyncEd is all about collaboration! Your photo helps others recognize you when they invite you to a lesson, and is shown in a lesson when you join one.")
                            .padding(.vertical, 10)
                    }
                    
                    ProfilePhotoManager(isLoading: $viewModel.isLoadingPhoto)
                        .padding(.vertical, 20)
                    
                    Button(action: viewModel.finishOnboardingHandler) {
                        ButtonTextPrimary(
                            text: "Finish onboarding",
                            isLoading: viewModel.isFinishingOnboarding || viewModel.isLoadingPhoto
                        )
                        .padding(.top, 8)
                    }
                    .disabled(viewModel.isFinishingOnboarding || viewModel.isLoadingPhoto)
                }
                .cardContainer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UploadPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        UploadPhotoView()
    }
}
