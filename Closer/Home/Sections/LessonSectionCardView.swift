//
//  LessonSectionCardView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/7/22.
//

import SwiftUI

struct LessonSectionCardView: View {
    
    @StateObject var viewModel = LessonSectionCardViewModel()
    
    let lesson: Lesson
    
    var body: some View {
        NavigationLink {
            LessonView(lesson: lesson)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                if let cover = viewModel.cover {
                    cover
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 220)
                        .clipShape(Rectangle())
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .frame(height: 200)
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(lesson.name)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    LessonLevelBadgeView(lesson.level)
                        .font(.system(size: 15))
                    Text("\(lesson.description)")
                        .lineLimit(2)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
            .frame(width: 300)
            .frame(maxHeight: .infinity)
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .onAppear() {
            viewModel.loadCoverImage(for: lesson.uid)
        }
    }
}

//struct LessonSectionCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LessonSectionCardView()
//    }
//}
