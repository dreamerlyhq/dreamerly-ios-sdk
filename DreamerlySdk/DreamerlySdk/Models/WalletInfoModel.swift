//
//  WalletInfoModel.swift
//  DreamerlyCrypto
//
//  Created by Quang on 05/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import Foundation

struct WalletInfoModel: Codable, Equatable {

    let address: String
    let chainId: String

    enum CodingKeys: String, CodingKey {
        case address
        case chainId
    }

    init(address: String, chainId: String) {
        self.address = address
        self.chainId = chainId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.address = try container.decode(String.self, forKey: .address)
        self.chainId = try container.decode(String.self, forKey: .chainId)
    }
}
