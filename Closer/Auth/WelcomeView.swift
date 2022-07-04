//
//  WelcomeView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/10/22.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 0) {
                    Image(geometry.size.height > geometry.size.width ? "WelcomeCover" : "WelcomeCoverLandscape")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome!")
                            .cardTitlePrimary()
                        Text("SyncEd allows teachers and students to pair up and study English like they are in a room together.")
                        NavigationLink {
                            EnterPhoneNumberView()
                        } label: {
                            ButtonTextPrimary(
                                text: "Sign in",
                                isLoading: false
                            )
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: 460)
                }
                Spacer()
            }
            .padding(.bottom, 12)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WelcomeView()
        }
    }
}
