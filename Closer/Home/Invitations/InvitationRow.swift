//
//  InvitationRow.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/13/22.
//

import SwiftUI

struct InvitationRowView: View {
    
    let invitation: Invitation
    @State var partnerPhoto: Image? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            if let partnerPhoto = partnerPhoto {
                partnerPhoto
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
            } else {
                Circle().frame(width: 56, height: 56).foregroundColor(.gray)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(invitation.partnerName)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Text("Invited you to join \(invitation.lesson.name)")
                    .foregroundColor(.secondary)
                    .font(.system(size: 15))
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color("gray-tertiary"))
        }
        .padding(.leading, 6)
        .padding(.trailing, 20)
        .padding(.vertical, 6)
        .background()
        .clipShape(Capsule())
        .frame(
            maxWidth: invitation.isHidden ? 0 : .infinity,
            maxHeight: invitation.isHidden ? 0 : .infinity
        )
        .onAppear {
            ImageHelpers.loadImage(for: invitation.partnerId, in: "avatars") { image in
                self.partnerPhoto = image
            }
        }
    }
}
