//
//  StoreInteractor.swift
//  DreamerlyCrypto
//
//  Created by Quang on 03/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import Foundation
import StoreKit
import Combine
import SwiftyStoreKit

protocol StoreInteractor {
    func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error>
    func purchaseProduct(productId: String) -> AnyPublisher<String, Error>
    func fetchReceipt() -> AnyPublisher<Data, Error>
}

// MARK: - Real

struct RealStoreInteractor: StoreInteractor {

    init() {}

    func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error> {
        return Deferred {
            Future { promise in
                SwiftyStoreKit.retrieveProductsInfo(Set(ids)) { result in
                    if !result.retrievedProducts.isEmpty {
                        promise(.success(result.retrievedProducts))
                    } else if let invalidProductId = result.invalidProductIDs.first {
                        print("Invalid product identifier: \(invalidProductId)")
                        let error = NSError(domain: "Invalid product identifier: \(invalidProductId)", code: 404)
                        promise(.failure(error))
                    } else {
                        if let error = result.error {
                            promise(.failure(error))
                        } else {
                            let error = NSError(domain: "Unkown Error", code: 500)
                            promise(.failure(error))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func purchaseProduct(productId: String) -> AnyPublisher<String, Error> {
        return Future { promise in
            SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
                switch result {
                case .success(let purchase):
                    guard let transactionId = purchase.transaction.transactionIdentifier else {
                        return
                    }
                    print("QQ: Purchase Success - Transaction Identifier: \(transactionId)")
                    promise(.success(transactionId))
                case .error(let error):
                    switch error.code {
                    case .unknown: print("Unknown error. Please contact support")
                    case .clientInvalid: print("Not allowed to make the payment")
                    case .paymentCancelled: break
                    case .paymentInvalid: print("The purchase identifier was invalid")
                    case .paymentNotAllowed: print("The device is not allowed to make the payment")
                    case .storeProductNotAvailable: print("The product is not available in the current storefront")
                    case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                    case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                    default: print((error as NSError).localizedDescription)
                    }
                    promise(.failure(error))
                case .deferred(purchase: let purchase):
                    guard let transactionId = purchase.transaction.transactionIdentifier else {
                        return
                    }
                    print("QQ: Purchase Success - Transaction Identifier: \(transactionId)")
                    promise(.success(transactionId))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchReceipt() -> AnyPublisher<Data, Error> {
        return Deferred {
            Future { promise in
                SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
                    switch result {
                    case .success(let receiptData):
                        print("QQ: Receipt String: ", receiptData.base64EncodedString())
                        promise(.success(receiptData))
                    case .error(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

final class StubStoreInteractor: StoreInteractor {
    func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func purchaseProduct(productId: String) -> AnyPublisher<String, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func fetchReceipt() -> AnyPublisher<Data, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
