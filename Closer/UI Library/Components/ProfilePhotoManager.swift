//
//  ProfilePhotoManager.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/23/22.
//

import SwiftUI
import AVKit

struct ProfilePhotoManager: View {
    
    @EnvironmentObject var authManager: AuthManager
    @Binding var isLoading: Bool
    
    @State var image: Image? = nil
    @State var showImagePicker: Bool = false
    @State var showCamera: Bool = false
    @State var showCameraDenied: Bool = false
    @State private var showDeletePhoto = false
    
    let previewDiameter: CGFloat = 240
    
    func initImage() {
        isLoading = true
        authManager.initImage() { image in
            self.image = image
            isLoading = false
        }
    }
    
    func uploadImageToStorage(_ image: UIImage) {
        isLoading = true
        authManager.uploadImageToStorage(image) { resizedImage in
            self.image = resizedImage
            isLoading = false
        }
    }
    
    func removePhoto() {
        isLoading = true
        showDeletePhoto = false
        authManager.removePhoto() { success in
            isLoading = false
            if success {
                self.image = nil
            }
        }
    }
    
    func launchCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.showCamera = true
                }
            }
        case .denied:
            showCameraDenied = true
            return
        case .restricted:
            return
        @unknown default:
            return
        }
    }
    
    func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { _ in })
        }
    }
    
    var body: some View {
        ZStack {
            Menu {
                Button(action: launchCamera) {
                    Label("Take a picture", systemImage: "camera")
                }
                Button(action: { self.showImagePicker = true }) {
                    Label("Upload from Library", systemImage: "photo.on.rectangle.angled")
                }
                if image != nil {
                    Button(action: { showDeletePhoto = true }) {
                        Label("Remove photo", systemImage: "trash")
                    }
                    
                }
            } label: {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .frame(width: previewDiameter * 1.1, height: previewDiameter * 1.1)
                            .foregroundColor(Color("bg-secondary"))
                        if image != nil {
                            image!
                                .resizable()
                                .scaledToFill()
                                .frame(width: previewDiameter, height: previewDiameter)
                                .clipShape(Circle())
                                .opacity(isLoading ? 0.3 : 1)
                        } else {
                            Circle()
                                .frame(width: previewDiameter, height: previewDiameter)
                                .foregroundColor(.white)
                        }
                    }
                    if image == nil {
                        Text("Add")
                            .foregroundColor(.accentColor)
                            .opacity(isLoading ? 0 : 1)
                    }
                }
                if isLoading {
                    Text("Loading...").foregroundColor(.secondary)
                }
            }
            .onAppear(perform: initImage)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                uploadImageToStorage(image)
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            VStack {
                ImagePicker(sourceType: .camera) { image in
                    uploadImageToStorage(image)
                }
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
        .alert("Remove photo?", isPresented: $showDeletePhoto) {
            Button("Remove", role: .destructive, action: removePhoto)
        } message: {
            Text("It will be deleted from your profile immediately.")
        }
        .alert("SyncEd Doesn’t Have Access to Camera", isPresented: $showCameraDenied) {
            Button("Open Settings App", action: openSettings)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You can allow SyncEd to use camera in the Settings app.")
        }
    }
}

struct ProfilePhotoManager_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePhotoManager(isLoading: .constant(false))
    }
}
