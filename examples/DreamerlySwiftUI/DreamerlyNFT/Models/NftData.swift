//
//  MockedModel.swift
//  CountriesSwiftUI
//
//  Created by Dreamerly on 27.10.2019.
//  Copyright © 2022 Dreamer. All rights reserved.
//

import Foundation

#if DEBUG

extension NftModel {
    static var nftStaticData: [NftModel] = {
        return [
            NftModel(id: "dreamerly.nft.01", title: "NFT 1", price: "1.99", image: "1", iosId: "dreamerly.nft.01"),
            NftModel(id: "dreamerly.nft.02", title: "NFT 2", price: "0.99", image: "2", iosId: "dreamerly.nft.02"),
            NftModel(id: "dreamerly.nft.03", title: "NFT 3", price: "2.99", image: "3", iosId: "dreamerly.nft.03"),
            NftModel(id: "dreamerly.nft.04", title: "NFT 4", price: "0.99", image: "4", iosId: "dreamerly.nft.04"),
            NftModel(id: "dreamerly.nft.05", title: "NFT 5", price: "1.99", image: "5", iosId: "dreamerly.nft.05"),
        ]
    }()
}

#endif
