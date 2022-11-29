//
//  LoginView.swift
//  DreamerlyCrypto
//
//  Created by Quang on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - LoginView
public struct LoginViewSdk: View {
    
    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Text("Connect with wallet")
                .font(.system(size: 18, weight: .semibold))

            Text("After you purchase NFTs via in-app purchases, NFTs and digital goods will be sent to your wallet. Per the App Store's policy, we do not facilitate virtual currency transmission.")
                .font(.system(size: 14))

            VStack(alignment: .center, spacing: 0) {
                WalletButtonView(
                    title: "MetaMask",
                    action: {
//                        loginWith(.MetaMask)
                    },
                    iconImage: Image("metamask-icon")
                )

                Divider()

                WalletButtonView(
                    title: "Trust Wallet",
                    action: {
//                        loginWith(.TrustWallet)
                    },
                    iconImage: Image("trustwallet-icon")
                )

                Divider()

                WalletButtonView(
                    title: "Rainbow",
                    action: {
//                        loginWith(.Rainbow)
                    },
                    iconImage: Image("rainbow-icon")
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("Greyscale-G3"), lineWidth: 1)
            )
        }
        .padding([.leading, .trailing], 16)
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginViewSdk()
    }
}
#endif
