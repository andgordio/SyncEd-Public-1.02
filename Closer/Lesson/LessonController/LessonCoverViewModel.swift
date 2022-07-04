//
//  LessonCoverViewModel.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/7/22.
//

import SwiftUI
import FirebaseStorage

// # Note
// This file is identical to LessonSectionCardViewModel
// # To do
// Merge them into a single helper / ObservableObject

class LessonCoverViewModel: ObservableObject {
    
    @Published var cover: Image?
    
    func loadCoverImage(for lessonId: String) {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("\(lessonId).jpg")
        
        if let data = try? Data(contentsOf: path) {
            createImage(from: data)
        } else {
            print("reaching out to cloud storage...")
            let pathReference = Storage.storage().reference(withPath: "lessonCovers/\(lessonId).jpg")
            pathReference.getData(maxSize: 3 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                } else {
                    guard let data = data else {
                        return
                    }
                    try? data.write(to: path)
                    self.createImage(from: data)
                }
            }
        }
    }
    
    func createImage(from data: Data) {
        let image = UIImage(data: data)
        if let image = image {
            self.cover = Image(uiImage: image)
        }
    }
    
}
