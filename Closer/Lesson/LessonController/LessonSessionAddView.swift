//
//  LessonSessionAdd.swift
//  Playgrounds
//
//  Created by Andriy Gordiyenko on 6/8/22.
//

import SwiftUI

struct LessonSessionAddView: View {
    
    let onTapGesture: () -> Void
    
    var body: some View {
        Button {
            onTapGesture()
        } label: {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color("bg-tertiary"))
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .foregroundColor(.accentColor)
                }
                Text("Create a new session")
                    .fontWeight(.medium)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
}

struct LessonSessionAddView_Previews: PreviewProvider {
    static var previews: some View {
        LessonSessionAddView(onTapGesture: { })
    }
}
