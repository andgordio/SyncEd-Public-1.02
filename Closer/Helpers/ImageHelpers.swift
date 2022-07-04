//
//  File.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/22/22.
//

import SwiftUI
import FirebaseStorage

struct ImageHelpers {
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func loadImage(for imageName: String, in folder: String, completion: @escaping (Image?) -> Void) {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("\(imageName).jpg")
        
        if let data = try? Data(contentsOf: path) {
            completion(createImage(from: data))
        } else {
            let pathReference = Storage.storage().reference(withPath: "\(folder)/\(imageName).jpg")
            pathReference.getData(maxSize: 3 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                    completion(Image("avatar-placeholder"))
                } else {
                    guard let data = data else {
                        completion(createPlacholder())
                        return
                    }
                    try? data.write(to: path)
                    completion(createImage(from: data))
                }
            }
        }
    }
    
    private static func createImage(from data: Data) -> Image {
        
        let image = UIImage(data: data)
        
        if let image = image {
            return Image(uiImage: image)
        } else {
            return createPlacholder()
        }
    }
    
    private static func createPlacholder() -> Image {
        return Image("avatar-placeholder")
    }
    
}
