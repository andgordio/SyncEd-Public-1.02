//
//  UserAvatar.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 5/30/22.
//

import SwiftUI

struct ThumbnailPlaceholder: View {
    var diameter: CGFloat
    var body: some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .foregroundColor(.black)
            .opacity(0.03)
    }
}

struct Thumbnail: View {
    var photo: Image
    var diameter: CGFloat
    init (_ photo: Image, diameter: CGFloat) {
        self.photo = photo
        self.diameter = diameter
    }
    var body: some View {
        photo
            .resizable()
            .scaledToFill()
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
    }
}
