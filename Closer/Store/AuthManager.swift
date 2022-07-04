//
//  AuthManager.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/20/22.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var didCheckAuthUser: Bool = false
    @Published var user: User?
    
    @Published var firestoreUser: FirestoreUser?
    
    public var db = Firestore.firestore()
    public let storage = Storage.storage()
    
    // MARK: - Authentication
    
    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            self.user = user
            self.didCheckAuthUser = true
            self.checkFirestoreUser()
        }
    }
    
    public func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (String?, Error?) -> Void) {
        
        #if targetEnvironment(simulator)
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        #endif
        
        PhoneAuthProvider.provider()
            .verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
                completion(verificationID, error)
            }
    }
    
    public func signIn(authVerificationID: String, code: String, completion:  @escaping (Error?) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: authVerificationID,
            verificationCode: code
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            completion(error)
        }
    }
    
    public func checkFirestoreUser() {
        if let user = self.user {
            let docRef = db.collection("users").document(user.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.firestoreUser = FirestoreUser(
                        uid: user.uid,
                        phoneNumber: document.data()!["phoneNumber"] as? String ?? "",
                        role: UserRole(rawValue: document.data()!["role"] as? String ?? ""),
                        name: document.data()!["name"] as? String ?? "",
                        didCompleteOnboarding: document.data()!["didCompleteOnboarding"] as? Bool ?? false
                    )
                } else {
                    self.db.collection("users").document(user.uid).setData([
                        "phoneNumber": user.phoneNumber ?? "",
                        "didCompleteOnboarding": false
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            self.firestoreUser = FirestoreUser(
                                uid: user.uid,
                                phoneNumber: user.phoneNumber ?? "",
                                name: "",
                                didCompleteOnboarding: false
                            )
                        }
                    }
                }
            }
        } else {
            self.firestoreUser = nil
        }
    }
    
    // MARK: - Onboarding
    
    public func updateRole(_ role: UserRole, completion: @escaping () -> Void) {
        if self.user != nil && self.firestoreUser != nil {
            let docRef = db.collection("users").document(self.user!.uid)
            docRef.setData([ "role": role.rawValue ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.firestoreUser!.role = role
                }
                completion()
            }
        } else {
            // Rerport&Handle:
            // Something went terribly wrong, both user entities shouldn’t be nil
            completion()
        }
    }
    
    public func initImage(completion: @escaping (Image?) -> Void) {
        var image: Image? = nil
        if let user = self.user {
            let pathReference = storage.reference(withPath: "avatars/\(user.uid).jpg")
            pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    // Rerport&Handle
                    print("Error \(error.localizedDescription)")
                } else {
                    let loadedImage = UIImage(data: data!)
                    if let loadedImage = loadedImage {
                        image = Image(uiImage: loadedImage)
                    }
                }
                completion(image)
            }
        } else {
            // Rerport&Handle:
            // Something went terribly wrong, both user entities shouldn’t be nil
        }
    }
    
    public func uploadImageToStorage(_ image: UIImage, completion: @escaping (Image?) -> Void) {
        if let user = self.user {
            let pathReference = storage.reference(withPath: "avatars/\(user.uid).jpg")
            let resizedImage = ImageHelpers.resizeImage(image: image, targetSize: CGSize(width: 1000, height: 1000))
            
            let data = resizedImage.jpegData(compressionQuality: 0.2)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            
            if let data = data {
                pathReference.putData(data, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error while uploading file: ", error)
                        completion(nil)
                    } else {
                        let resizedImageView = Image(uiImage: resizedImage)
                        completion(resizedImageView)
                    }
                    if let metadata = metadata {
                        print("Metadata: ", metadata)
                    }
                }
            }
        } else {
            // Rerport&Handle:
            // Something went terribly wrong, both user entities shouldn’t be nil
        }
    }
    
    public func removePhoto(completion: @escaping (Bool) -> Void) {
        if let user = self.user {
            let pathReference = storage.reference(withPath: "avatars/\(user.uid).jpg")
            pathReference.delete { error in
                if let _ = error {
                    // Report & Handle:
                    // Either reference is bad, or the connection, or something else
                    // Check the error message variants
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } else {
            // Rerport&Handle:
            // Something went terribly wrong, both user entities shouldn’t be nil
        }
    }
    
    public func finishOnboarding(completion: @escaping () -> Void) {
        if self.user != nil && self.firestoreUser != nil {
            let docRef = db.collection("users").document(self.user!.uid)
            docRef.setData([ "didCompleteOnboarding": true ], merge: true) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.firestoreUser!.didCompleteOnboarding = true
                }
                completion()
            }
        } else {
            // Rerport&Handle:
            // Something went terribly wrong, both user entities shouldn’t be nil
            completion()
        }
    }
    
    // MARK: - Settings
    
    public func signOut(_ completion: () -> Void) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        completion()
    }
}


