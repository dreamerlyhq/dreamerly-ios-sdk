//
//  PrimaryButtonView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 08/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI

struct PrimaryButtonView: View {
    private let buttonTitle: String
    private let buttonAction: (() -> Void)

    init(buttonTitle: String, buttonAction: @escaping (() -> Void)) {
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(buttonTitle)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
                .padding([.top, .bottom], 12)
                .frame(maxWidth: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(hex: "#0061D7"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#0061D7"), lineWidth: 1)
                
        )
        .contentShape(Rectangle())
    }
}

struct PrimaryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryButtonView(buttonTitle: "Buy") {
            print("QQ")
        }
    }
}
