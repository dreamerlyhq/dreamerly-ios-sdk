//
//  TransactionStatus+Extension.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 08/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import Foundation

extension TransactionStatus {
    var title: String {
        switch self {
        case .purchased, .deliveryPending:
            return "Pending Delivery"
        case .delivered:
            return "Delivered"
        }
    }

    var shouldShowSubTitle: Bool {
        switch self {
        case .purchased, .deliveryPending:
            return true
        case .delivered:
            return false
        }
    }

    var color: String {
        switch self {
        case .purchased, .deliveryPending:
            return "#0061D7"
        case .delivered:
            return "#00CC45"
        }
    }
}
