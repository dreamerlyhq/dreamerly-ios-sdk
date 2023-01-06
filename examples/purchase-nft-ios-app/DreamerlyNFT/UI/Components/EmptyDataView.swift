//
//  EmptyDataView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 08/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI

struct EmptyDataView: View {
    private let buttonTitle: String?
    private let buttonAction: (() -> Void)?

    init(buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    var body: some View {
        VStack {
            Image("empty-background")
                .frame(width: 250, height: 200)
            
            Text("You dont have any transactions yet")
                .font(.system(size: 16, weight: .semibold))
                .padding(.top, 24)

            Text("Explore and buy more NFTs")
                .font(.system(size: 14))
                .padding(.top, 8)

            if let unwrapButtonTitle = buttonTitle {
                PrimaryButtonView(buttonTitle: unwrapButtonTitle) {
                    buttonAction?()
                }
                .padding(.top, 24)
            }
        }
    }
}

struct EmptyDataView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyDataView(buttonTitle: "Explore NFTs")
            .padding()
    }
}
