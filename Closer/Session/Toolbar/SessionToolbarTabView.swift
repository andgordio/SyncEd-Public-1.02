//
//  SessionToolbarTabView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/15/22.
//

import SwiftUI

struct SessionToolbarTabView: View {
    
    @StateObject var player = PlayerViewController.shared
    
    var section: LessonSection
    var myPageIndex: Int
    
    var partnerPageIndex: Int?
    var partnerPhoto: Image?
    
    var tasks: [LessonTask]
    
    var onTapGesture: () -> Void
    
    var isPlayerActiveOnPage: Bool {
        let filteredTasks = tasks.filter { $0.sectionId == section.uid }
        let taskWithActivePlayer = filteredTasks.first(where: { $0.uid == player.fileOnPlayback })
        return taskWithActivePlayer != nil
    }
    
    var body: some View {
        Button {
            onTapGesture()
        } label: {
            VStack() {
                HStack(spacing: -10) {
                    if partnerPageIndex == section.order {
                        if let partnerPhoto = partnerPhoto {
                            ZStack {
                                partnerPhoto
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 21, height: 21)
                                    .clipShape(Circle())
                                Circle()
                                    .stroke(.background, lineWidth: 1)
                                    .frame(width: 21, height: 21)
                                    .padding(0)
                            }
                        } else {
                            ZStack {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 21, height: 21)
                                    .padding(0)
                                Circle()
                                    .stroke(.background, lineWidth: 1)
                                    .frame(width: 21, height: 21)
                                    .padding(0)
                            }
                        }
                    }
                    if isPlayerActiveOnPage {
                        ZStack {
                            Circle()
                                .frame(width: 21, height: 21)
                                .foregroundColor(player.player?.isPlaying ?? false ? .accentColor : .gray)
                            Circle()
                                .stroke(.background, lineWidth: 1)
                                .frame(width: 21, height: 21)
                            Image(systemName: "music.note")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 11)
                                .foregroundColor(.white)
                        }
                    }
                }
                Spacer()
                RoundedRectangle(cornerRadius: 100)
                    .frame(height: myPageIndex == section.order ? 3 : 1)
                    .foregroundColor(myPageIndex == section.order ? .accentColor : .gray)
                    .padding(.bottom, myPageIndex == section.order ? 0 : 1)
                    .opacity(myPageIndex == section.order ? 1 : 0.3)
            }
            .frame(height: 33)
            .frame(maxWidth: .infinity)
        }
    }
}
