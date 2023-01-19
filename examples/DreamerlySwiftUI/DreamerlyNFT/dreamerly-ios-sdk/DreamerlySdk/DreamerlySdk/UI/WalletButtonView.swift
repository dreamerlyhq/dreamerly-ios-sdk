//
//  WalletButtonView.swift
//  DreamerlyCrypto
//
//  Created by Quang on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI

struct WalletButtonView: View {
    let title: String
    let action: () -> Void
    let iconImage: Image

    let buttonBackground: Color = Color.white
    let buttonForeground: Color = Color.black
    let iconSize: CGFloat = 24

    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 12) {
                iconImage
                    .resizable()
                    .frame(width: iconSize, height: iconSize)

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(buttonForeground)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }
        })
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .background(buttonBackground)
        .foregroundColor(buttonForeground)
        .padding(12)
    }
}

struct WalletButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .center, spacing: 0) {
            WalletButtonView(
                title: "MetaMask",
                action: {},
                iconImage: Image("metamask-icon")
            )

            Divider()

            WalletButtonView(
                title: "Trust Wallet",
                action: {},
                iconImage: Image("trustwallet-icon")
            )

            Divider()

            WalletButtonView(
                title: "Rainbow",
                action: {},
                iconImage: Image("rainbow-icon")
            )
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
    }
}
