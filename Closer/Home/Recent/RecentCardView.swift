//
//  RecentCard.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/14/22.
//

import SwiftUI

struct RecentCardView: View {
    
    var recent: Invitation
    @State var cover: Image? = nil
    @State var partnerPhoto: Image? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let cover = cover {
                cover
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Rectangle())
            } else {
                Rectangle()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("bg-tertiary"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(recent.lesson.name)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        LessonLevelBadgeView(recent.lesson.level)
                            .font(.system(size: 15))
                        Text(
                            recent.partnerId.isEmpty ? "No partner" :
                                recent.partnerName.isEmpty ? "Some partner" : recent.partnerName
                        )
                        .lineLimit(1)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    }
                    Spacer()
                    if let partnerPhoto = partnerPhoto {
                        partnerPhoto
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                }
                .padding(.trailing, 10)
            }
            .padding(.top, 12)
            .padding(.bottom, 10)
        }
        .frame(width: 300)
        .frame(maxHeight: .infinity)
        .background()
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            ImageHelpers.loadImage(for: recent.lesson.uid, in: "lessonCovers") { image in
                self.cover = image
            }
            if !recent.partnerId.isEmpty {
                ImageHelpers.loadImage(for: recent.partnerId, in: "avatars") { image in
                    if let image = image {
                        self.partnerPhoto = image
                    } else {
                        self.partnerPhoto = Image("avatar-placeholder")
                    }
                }
            }
        }
    }
}

struct RecentCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentCardView(
            recent: Invitation(
                sessionId: "test-session-id",
                partnerId: "3Y91FknnpWU2XlbUMj6KuB3WUos2",
                partnerName: "Preview Tester",
                lesson: Lesson(
                    uid: "test-lesson-id",
                    name: "Preview Lesson",
                    description: "A preview lesson for testing purposes",
                    level: .beginner
                ),
                isHidden: false
            )
        )
    }
}
