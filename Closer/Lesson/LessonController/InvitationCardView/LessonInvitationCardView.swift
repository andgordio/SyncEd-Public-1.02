//
//  LessonInvitationCard.swift
//  Playgrounds
//
//  Created by Andriy Gordiyenko on 6/8/22.
//

import SwiftUI

struct LessonInvitationCardView: View {
    
    @StateObject var viewModel = LessonInvitationCardViewModel()
    
    let session: FirestoreSession
    let cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundColor(.white)
                    .frame(width: 290, height: 192)
            .overlay {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .frame(width: 88, height: 88)
                            .foregroundColor(.white)
                        if let partnerPhoto = viewModel.partnerPhoto {
                            partnerPhoto
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .frame(width: 80, height: 80)
                                .foregroundColor(Color("bg-secondary"))
                        }
                    }
                    .padding(.top, -48)
                    Text(viewModel.partnerName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("Invited you to join their session").foregroundColor(.gray)
                    HStack {
                        Button {
                            viewModel.acceptInvitation()
                        } label: {
                            Text("Accept")
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color("bg-secondary"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        Button {
                            viewModel.declineInvitation()
                        } label: {
                            Text("Decline")
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color("bg-secondary"))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 48)
            .onAppear {
                viewModel.initiateViewModel(for: session)
            }
    }
}
