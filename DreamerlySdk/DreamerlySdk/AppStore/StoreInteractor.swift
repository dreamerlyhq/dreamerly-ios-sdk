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
    func checkNftStatus(transactionId: String, apiKey: String) -> AnyPublisher<String, Error>
    func fetchReceipt() -> AnyPublisher<Data, Error>
//    func sendReceiptData(dmIosPurchaseData: DmIosPurchaseData,
//                         dmNftData: DmNftData,
//                         apiKey: String) -> AnyPublisher<Data, Error>
}

//// MARK: - Public data object
//public struct DmIosPurchaseData {
//    public init(transactionId: String, productId: String, transactionDateTime: String, receiptData: Data, customerId: String) {
//        self.transactionId = transactionId
//        self.productId = productId
//        self.transactionDateTime = transactionDateTime
//        self.receiptData = receiptData
//        self.customerId = customerId
//    }
//
//    public let transactionId: String
//    public let productId: String
//    public let transactionDateTime: String
//    public let receiptData: Data
//    public let customerId: String
//}
//
//public struct DmNftData {
//    public init(nftCollectionId: String, nftMetadata: String, nftMetadataIp: String, nftDisplayName: String, nftDescription: String, nftImageUrl: String, fromAddress: String, toAddress: String, chainId: String) {
//        self.nftCollectionId = nftCollectionId
//        self.nftMetadata = nftMetadata
//        self.nftMetadataIp = nftMetadataIp
//        self.nftDisplayName = nftDisplayName
//        self.nftDescription = nftDescription
//        self.nftImageUrl = nftImageUrl
//        self.fromAddress = fromAddress
//        self.toAddress = toAddress
//        self.chainId = chainId
//    }
//
//    public let nftCollectionId: String
//    public let nftMetadata: String
//    public let nftMetadataIp: String
//    public let nftDisplayName: String
//    public let nftDescription: String
//    public let nftImageUrl: String
//    public let fromAddress: String
//    public let toAddress: String
//    public let chainId: String
//}
//
//// MARK: - Real
//
//struct DmPayloadData: Codable {
//    let transactionId: String
//    let productId: String
//    let transactionDateTime: String
//    let receiptData: String
//    let customerId: String
//    let nftCollectionId: String
//    let nftMetadata: String
//    let nftMetadataIp: String
//    let nftDisplayName: String
//    let nftDescription: String
//    let nftImageUrl: String
//    let fromAddress: String
//    let toAddress: String
//    let chainId: String
//    let platform: String
//    let status: String
//}

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
    
    public func checkNftStatus(transactionId: String, apiKey: String) -> AnyPublisher<String, Error> {
        return Future { promise in
            let url = URL(string: "https://q84s1po7xi.execute-api.us-east-1.amazonaws.com/prod/nfts/" + transactionId)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // TODO figure out how to handle error and retry case here that don't make client redo the IAP flow w/ Apple
                if let error = error {
                    print ("error: \(error)")
                    promise(.failure(error))
                    return
                }
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode) else {
                    print ("server error")
                    promise(.success("Failed"))
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                   let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    promise(.success(dataString))
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
    
//    public func sendReceiptData(dmIosPurchaseData: DmIosPurchaseData,
//                                dmNftData: DmNftData,
//                                apiKey: String) -> AnyPublisher<Data, Error> {
//
//        return Deferred {
//            Future { promise in
//                let payloadData = DmPayloadData(transactionId: dmIosPurchaseData.transactionId, productId: dmIosPurchaseData.productId, transactionDateTime: dmIosPurchaseData.transactionDateTime, receiptData: dmIosPurchaseData.receiptData.base64EncodedString(), customerId: dmIosPurchaseData.customerId, nftCollectionId: dmNftData.nftCollectionId, nftMetadata: dmNftData.nftMetadata, nftMetadataIp: dmNftData.nftMetadataIp, nftDisplayName: dmNftData.nftDisplayName, nftDescription: dmNftData.nftDescription, nftImageUrl: dmNftData.nftImageUrl, fromAddress: dmNftData.fromAddress, toAddress: dmNftData.toAddress, chainId: dmNftData.chainId, platform: "ios", status: "PURCHASED")
//
//                guard let uploadData = try? JSONEncoder().encode(payloadData) else {
//                    promise(.success(dmIosPurchaseData.receiptData))
//                    return
//                }
//
//                let url = URL(string: "https://q84s1po7xi.execute-api.us-east-1.amazonaws.com/prod/receipt")!
//                var request = URLRequest(url: url)
//                request.httpMethod = "POST"
//                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
//
//                let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
//                    // TODO figure out how to handle error and retry case here that don't make client redo the IAP flow w/ Apple
//                    if let error = error {
//                        print ("error: \(error)")
//                        promise(.failure(error))
//                        return
//                    }
//                    guard let response = response as? HTTPURLResponse,
//                        (200...299).contains(response.statusCode) else {
//                        print ("server error")
//                        promise(.success(dmIosPurchaseData.receiptData))
//                        return
//                    }
//                    if let mimeType = response.mimeType,
//                        mimeType == "application/json",
//                        let data = data,
//                        let dataString = String(data: data, encoding: .utf8) {
//                        print(data)
//                        print ("got data: \(dataString)")
//                        promise(.success(dmIosPurchaseData.receiptData))
//                    }
//                }
//                task.resume()
//            }
//        }
//        .eraseToAnyPublisher()
//
//    }
}

public final class StubStoreInteractor: StoreInteractor {
    
    public init() {}
    
    public func getProducts(ids: [String]) -> AnyPublisher<Set<SKProduct>, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    public func purchaseProduct(productId: String) -> AnyPublisher<String, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
    public func checkNftStatus(transactionId: String, apiKey: String) -> AnyPublisher<String, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    public func fetchReceipt() -> AnyPublisher<Data, Error> {
        return Empty(completeImmediately: true).eraseToAnyPublisher()
    }
    
//    public func sendReceiptData(dmIosPurchaseData: DmIosPurchaseData,
//                                dmNftData: DmNftData,
//                                apiKey: String) -> AnyPublisher<Data, Error> {
//        return Empty(completeImmediately: true).eraseToAnyPublisher()
//    }
}
