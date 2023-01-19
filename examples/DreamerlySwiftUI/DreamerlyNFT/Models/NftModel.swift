//
//  NftModel.swift
//  DreamerlyCrypto
//
//  Created by Quang on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import Foundation
import StoreKit

struct NftModel: Identifiable, Hashable {
    let id: String
    let title: String
    let price: String
    let image: String?
    let iosId: String?

    var transactionStatus: TransactionStatus?

    init(id: String, title: String, price: String, image: String, iosId: String?) {
        self.id = id
        self.title = title
        self.price = price
        self.image = image
        self.iosId = iosId
    }

    static func == (lhs: NftModel, rhs: NftModel) -> Bool {
        return lhs.id == rhs.id
    }

    // Conform to the Hashable protocol
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
