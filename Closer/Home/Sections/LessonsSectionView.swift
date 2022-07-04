//
//  LessonsSection.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/2/22.
//

import SwiftUI

struct LessonsSectionView: View {
    
    @StateObject var viewModel = LessonsSectionViewModel()
    var level: LessonLevel
    
    var body: some View {
        VStack(spacing: 18) {
            
            HStack {
                Text(level.capitalizedName)
                Spacer()
            }
            .font(.system(size: 22, weight: .semibold))
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.lessons, id: \.uid) { lesson in
                        // TODO:
                        // move the navigationlink here from within the child
                        // & send primitive parameters to the child
                        // to make testing easier.
                        LessonSectionCardView(lesson: lesson)
                    }
                }
                .padding(.leading)
                .padding(.trailing)
            }
        }
        .padding(.top, 32)
        .onAppear() {
            viewModel.loadLessons(for: level)
        }
    }
}

//struct LessonsSection_Previews: PreviewProvider {
//    static var previews: some View {
//        LessonsSection()
//    }
//}
