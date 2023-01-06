//
//  TransactionStatusView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 08/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI

struct TransactionStatusView: View {

    let transactionStatus: TransactionStatus

    var body: some View {
        Text(transactionStatus.title)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding([.top, .bottom], 4)
            .padding([.leading, .trailing], 8)
            .background(Color(hex: transactionStatus.color))
            .cornerRadius(8)
    }
}

struct TransactionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionStatusView(transactionStatus: .purchased)
    }
}
