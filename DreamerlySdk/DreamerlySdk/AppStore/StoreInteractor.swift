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

public protocol StoreInteractor {
    func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error>
    func purchaseProduct(productId: String) -> AnyPublisher<String, Error>
    func checkNftStatus(transactionMetadataId: String, apiKey: String) -> AnyPublisher<NftTransactionData, Error>
    func fetchReceipt() -> AnyPublisher<Data, Error>
    func createNftTransaction(payload: CreateNftTransactionData,
                         apiKey: String) -> AnyPublisher<NftTransactionData, Error>
}

//// MARK: - Public data object

public struct CreateNftTransactionData: Codable {
    public init(apple_transaction_id: String, from_address: String, to_address: String, chain_id: String, platform: String, apple_product_id: String, receipt_data: String, purchase_date_time: String, nft_display_name: String, nft_description: String, nft_image_url: String, nft_collection_id: String, nft_collection_contract_address: String, apple_customer_id: String) {
        self.apple_transaction_id = apple_transaction_id
        self.from_address = from_address
        self.to_address = to_address
        self.chain_id = chain_id
        self.platform = platform
        self.apple_product_id = apple_product_id
        self.receipt_data = receipt_data
        self.purchase_date_time = purchase_date_time
        self.nft_display_name = nft_display_name
        self.nft_description = nft_description
        self.nft_image_url = nft_image_url
        self.nft_collection_id = nft_collection_id
        self.nft_collection_contract_address = nft_collection_contract_address
        self.apple_customer_id = apple_customer_id
    }
    
    public let apple_transaction_id: String
    public let from_address: String
    public let to_address: String
    public let chain_id: String
    public let platform: String
    public let apple_product_id: String
    public let receipt_data: String
    public let purchase_date_time: String
    public let nft_display_name: String
    public let nft_description: String
    public let nft_image_url: String
    public let nft_collection_id: String
    public let nft_collection_contract_address: String
    public let apple_customer_id: String
}

public struct NftData: Codable {
    public var metadata: String?
    public var nft_display_name: String?
    public var nft_description: String?
    public var image_url: String?
    public var token_id: String?
}

public struct NftBlockchain: Codable {
    public var from_address: String?
    public var to_address: String?
    public var asset_contract_address: String?
    public var transaction_hash: String?
}

public struct NftTransactionData: Codable {
    public var transaction_id: String
    public var nft: NftData
    public var blockchain: NftBlockchain
    public var chain_id: String
    public var status: String
}

public struct RealStoreInteractor: StoreInteractor {

    public init() {}

    public func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error> {
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

    public func purchaseProduct(productId: String) -> AnyPublisher<String, Error> {
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
    
    public func checkNftStatus(transactionMetadataId: String, apiKey: String) -> AnyPublisher<NftTransactionData, Error> {
        return Future { promise in
            let url = URL(string: "https://test-api.dreamerly.com/transactions/" + transactionMetadataId)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print ("error: \(error)")
                    promise(.failure(error))
                    return
                }
//                guard let response = response as? HTTPURLResponse,
//                    (200...299).contains(response.statusCode) else {
//                    print ("server error")
//                    promise(.failure(error))
//                    return
//                }

                let decoder = JSONDecoder()
                if let data = data {
                    do {
                        let nftData = try decoder.decode(NftTransactionData.self, from: data)
                        promise(.success(nftData))
                    } catch {
                        print(error.localizedDescription)
                        promise(.failure(error))
                    }
                }
            }
            task.resume()
        }
        .eraseToAnyPublisher()
    }

    public func fetchReceipt() -> AnyPublisher<Data, Error> {
        return Deferred {
            Future { promise in
                SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
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
    
    public func createNftTransaction(payload: CreateNftTransactionData,
                                apiKey: String) -> AnyPublisher<NftTransactionData, Error> {

        return Deferred {
            Future { promise in

                guard let uploadData = try? JSONEncoder().encode(payload) else {
                    return
                }

                let url = URL(string: "https://test-api.dreamerly.com/transactions")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

                let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
                    if let error = error {
                        print ("error: \(error)")
                        promise(.failure(error))
                        return
                    }
//                    guard let response = response as? HTTPURLResponse,
//                        (200...299).contains(response.statusCode) else {
//                        print ("server error")
//                        promise(.success("Server Error"))
//                        return
//                    }
                    let decoder = JSONDecoder()
                    if let data = data {
                        do {
                            let nftData = try decoder.decode(NftTransactionData.self, from: data)
                            promise(.success(nftData))
                        } catch {
                            print(error.localizedDescription)
                            promise(.failure(error))
                        }
                    }
                }
                task.resume()
            }
        }
        .eraseToAnyPublisher()

    }
}

public final class StubStoreInteractor: StoreInteractor {
    
    public init() {}
    
    public func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    public func purchaseProduct(productId: String) -> AnyPublisher<String, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    public func checkNftStatus(transactionMetadataId: String, apiKey: String) -> AnyPublisher<NftTransactionData, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    public func fetchReceipt() -> AnyPublisher<Data, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    public func createNftTransaction(payload: CreateNftTransactionData,
                                apiKey: String) -> AnyPublisher<NftTransactionData, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
