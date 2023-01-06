//
//  LoginStatusView.swift
//  DreamerlyNFT
//
//  Created by Quang on 18/11/2022.
//

import SwiftUI

struct LoginStatusView: View {
    private let buttonTitle: String?
    private let buttonAction: (() -> Void)?
    private let buttonActionSetAddress: (() -> Void)?
    private let title: String
    private let subtitle: String
    private let disclaimer: String
    
    @State private var walletAddress: String = ""

    init(buttonTitle: String? = nil, title: String = "", subtitle: String = "", disclaimer: String = "", buttonAction: (() -> Void)? = nil, buttonActionSetAddress: (() -> Void)? = nil) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.buttonActionSetAddress = buttonActionSetAddress
        self.title = title
        self.subtitle = subtitle
        self.disclaimer = disclaimer
    }

    var body: some View {
        VStack(alignment: .center) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .frame(alignment: .center)
            
            Image("login-status-background")
                .frame(width: 250, height: 200)

            Text(subtitle)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .frame(alignment: .center)

            Text(disclaimer)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            if let unwrapButtonTitle = buttonTitle {
                VStack(alignment: .center) {
                    PrimaryButtonView(buttonTitle: "Enter address") {
                        buttonActionSetAddress?()
                    }
                    
                    Text("OR")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.top, 4)
                    
                    PrimaryButtonView(buttonTitle: unwrapButtonTitle) {
                        buttonAction?()
                    }
                }
//                .padding([.leading, .trailing], 16)
            }
        }
        .padding([.leading, .trailing], 16)
    }
}

struct LoginStatusView_Previews: PreviewProvider {
    static var previews: some View {
        LoginStatusView(buttonTitle: "Sign in")
            .padding()
    }
}
