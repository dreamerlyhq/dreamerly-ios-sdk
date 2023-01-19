//
//  NftItemView.swift
//  DreamerlyCrypto
//
//  Created by Quang on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Amplify

struct NftItemView: View {
    private let model: NftModel

    init(model: NftModel) {
        self.model = model
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(model.title)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 10)

                if let transactionStatus = model.transactionStatus {
                    TransactionStatusView(transactionStatus: transactionStatus)
                    
                    Spacer(minLength: 0)
                }
            }

            Image(model.image ?? "")
                .resizable()
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .scaledToFill()

            HStack(spacing: 12) {
                Text("Price")
                    .font(.system(size: 16))

                Text("$\(model.price)")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()
            }
        }
    }
}

#if DEBUG
struct NftItemView_Previews: PreviewProvider {
    static var previews: some View {
        NftItemView(model: NftModel.nftStaticData[0])
    }
}
#endif
