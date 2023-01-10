//
//  NftDetailView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 10/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
//import Glaip
import StoreKit
import Amplify
import DreamerlySdk

// MARK: - Routing
extension NftDetailView {
    struct Routing: Equatable {
    }
}
// MARK: - Data Object
struct BackendPayloadData: Codable {
    let transactionId: String
    let productId: String
    let transactionDateTime: String
    let receiptData: String
    let customerId: String
    let nftDisplayName: String
    let nftDescription: String
    let nftImageUrl: String
    let fromAddress: String
    let toAddress: String
    let chainId: String
    let platform: String
}

// MARK: - TemplateView
struct NftDetailView: View {

    private let nftModel: NftModel

    // MARK: - States

    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<NftModel>

    @State private(set) var walletInfoModel: WalletInfoModel?
    @State private(set) var skProduct: SKProduct?
    @State private(set) var nftTransactionStatus: TransactionStatus?
    @State private(set) var enableBuyButton: Bool = true
    @State private(set) var isShowingLoginScreen: Bool = false
    @State private(set) var isShowingLoginStatusScreen: Bool = false
    @State private(set) var isShowingSetAddressScreen: Bool = false

    // MARK: - Binding

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.nftDetail)
    }

    // MARK: - Environment

    @ObservedObject private var glaip: Glaip

    @Environment(\.injected) private var injected: DIContainer

    private let cancelBag = CancelBag()

    init(nftModel: NftModel, data: Loadable<NftModel> = .notRequested) {
        self.nftModel = nftModel
        self._data = .init(initialValue: data)

        self.glaip = Glaip(
            title: "Dreamerly",
            description: "Dreamerly",
            clientUrl: "https://dreamerly.com",
            supportedWallets: [.Rainbow, .TrustWallet])
    }

    var body: some View {
        self.content
            .onReceive(routingUpdate) { self.routingState = $0 }
            .onReceive(walletInfoModelUpdate) { self.walletInfoModel = $0 }
    }

    // MARK: - Loading Status

    @ViewBuilder private var content: some View {
        switch data {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case let .loaded(loadedData):
            loadedView(loadedData)
        case let .failed(error):
            failedView(error)
        }
    }

    var notRequestedView: some View {
        Text("")
            .onAppear {
                fetchData(nftModel)
            }
    }

    func loadingView(_ previouslyLoaded: NftModel?) -> some View {
        if let data = previouslyLoaded {
            return AnyView(
                ZStack {
                    loadedView(data)
                        .opacity(0.4)
                        .disabled(true)

                    ActivityIndicatorView()
                        .padding()
                }
            )
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            // TODO: Reload Actions
        })
    }

    func loadedView(_ nftModel: NftModel) -> some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                Image(nftModel.image ?? "")
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .frame(height: 320)
                    .scaledToFill()

                HStack {
                    Text(nftModel.title)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 10)

                    if let transactionStatus = self.nftTransactionStatus {
                        TransactionStatusView(transactionStatus: transactionStatus)

                        Spacer(minLength: 0)
                    }
                }

                HStack(spacing: 12) {
                    Text("Price")
                        .font(.system(size: 16))

                    Text("$\(nftModel.price)")
                        .font(.system(size: 16, weight: .semibold))

                    Spacer()
                }

                if let transactionStatus = self.nftTransactionStatus, transactionStatus.shouldShowSubTitle {
                    Text("We will send the NFT to your wallet in the next 2, 3 days")
                        .font(.system(size: 14))
                }

                Spacer()

                PrimaryButtonView(buttonTitle: "Buy") {
                    buyNFT(model: nftModel)
                }
                .disabled(!enableBuyButton)
                .opacity(enableBuyButton ? 1 : 0.5)
            }
        }
        .padding(16)
        .sheet(isPresented: $isShowingLoginStatusScreen) {
            fetchData(nftModel)
        } content: {
//            LoginView(data: .loaded(()), glaip: glaip, isShowingLoginScreen: $isShowingLoginScreen)
            LoginStatusView(buttonTitle: "Connect with wallet app", title: "Set delivery wallet address",
                            subtitle: "After you purchase NFTs via in-app purchases, the NFTs and digital goods will be sent to your wallet. Please enter your wallet address, or connect with your wallet app.", disclaimer: "Per the App Store's policy, we do not facilitate virtual currency transmission.",
                            buttonAction: showLoginView, buttonActionSetAddress: showSetAddressView)
        }
        .sheet(isPresented: $isShowingLoginScreen) {
            LoginView(data: .loaded(()), glaip: glaip, isShowingLoginScreen: $isShowingLoginScreen)
        }
        .sheet(isPresented: $isShowingSetAddressScreen) {
            SetAddressView(data: .loaded(()), isShowingSetAddressScreen: $isShowingSetAddressScreen)
        }
    }
}

// MARK: - Side Effect
private extension NftDetailView {
    private func showLoginView() {
        print("QQ: Present Login View")
        isShowingLoginStatusScreen.toggle()
        isShowingLoginScreen.toggle()
    }
    
    private func showSetAddressView() {
        print("QQ: Present Set Address View")
        isShowingLoginStatusScreen.toggle()
        isShowingSetAddressScreen.toggle()
    }
    
    private func fetchData(_ nftModel: NftModel) {
        guard let iosIapId = nftModel.iosId else { return }
        var nftTransactions = injected.appState[\.userData.nftTransactions]
        let nftTransactionMetadataId = nftTransactions[iosIapId]
        self.nftTransactionStatus = nftModel.transactionStatus
        

        data.setIsLoading(cancelBag: cancelBag)

        injected.interactors.storeInteractor.getProducts(ids: [iosIapId])
            .sink { completion in
                switch completion {
                case .failure(let error):
                    data = .failed(error)
                case .finished:
                    data = .loaded(nftModel)
                }
            } receiveValue: { result in
                let (skProducts) = result
                if let skProduct = skProducts.filter({ $0.productIdentifier == iosIapId }).first {
                    self.skProduct = skProduct
                }
            }
            .store(in: cancelBag)
        
        if let nftTransactionMetadataId = nftTransactionMetadataId, nftTransactionMetadataId != "" {
            print(nftTransactionMetadataId)
            injected.interactors.storeInteractor.checkNftStatus(transactionMetadataId: nftTransactionMetadataId, apiKey: "uq6BUDT7SU4GAl8DmbwlL3ygTRfq5Vvp38YxEnK6")
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        data = .failed(error)
                    case .finished:
                        data = .loaded(nftModel)
                    }
                } receiveValue: { result in
                    self.nftTransactionStatus = TransactionStatus(rawValue: result.status)
//                    self.nftTransactionStatus = .delivered
                }
                .store(in: cancelBag)
        }
    }

    private func buyNFT(model: NftModel) {
        guard let walletInfoModel = injected.appState[\.userData.walletInfoModel] else {
            isShowingLoginStatusScreen.toggle()
            return
        }

        guard let iosId = model.iosId else { return }
        guard let nftImage = model.image else { return }
        let nftTitle = model.title

        data.setIsLoading(cancelBag: cancelBag)
        injected.interactors.storeInteractor.purchaseProduct(productId: iosId)
            .flatMap { transactionId in
                return injected.interactors.storeInteractor
                    .fetchReceipt()
                    .map { receiptData -> (Data, String) in
                        return (receiptData, transactionId)
                    }
            }
            .flatMap { (receiptData, transactionId) in
                return injected.interactors.storeInteractor.createNftTransaction(payload: CreateNftTransactionData(apple_transaction_id: transactionId, from_address: "0xb16FA799C006bfDe739d2408737EA8a897198CB3", to_address: walletInfoModel.address, chain_id: "POLYGON_MUMBAI", platform: "ios", apple_product_id: iosId, receipt_data: receiptData.base64EncodedString(), purchase_date_time: Temporal.DateTime.now().iso8601String, nft_display_name: nftTitle, nft_description: nftTitle, nft_image_url: nftImage, nft_collection_id: "fa440767-c09e-4c77-97e4-ff34b7dfeb57", nft_collection_contract_address: "0x956ae03E8D4BbE4bB3bcb15c1a85F7BA07374904", apple_customer_id: "mockCustomerId1"), apiKey: "uq6BUDT7SU4GAl8DmbwlL3ygTRfq5Vvp38YxEnK6")
            }
            .collect()
            .sink { completion in
                switch completion {
                case .failure(_):
                    data.cancelLoading()
                case .finished:
                    fetchData(model)
                }
            } receiveValue: { result in
                let transactionMetadataId = result[0].transaction_id
                print(transactionMetadataId)
                guard let iosIapId = nftModel.iosId else { return }
                var nftTransactions = injected.appState[\.userData.nftTransactions]
                nftTransactions[iosIapId] = transactionMetadataId
                injected.appState[\.userData.nftTransactions] = nftTransactions
            }
            .store(in: cancelBag)
    }
    
}

// MARK: - State Updates
private extension NftDetailView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.nftDetail)
    }

    var walletInfoModelUpdate: AnyPublisher<WalletInfoModel?, Never> {
        injected.appState.updates(for: \.userData.walletInfoModel?)
    }
}

#if DEBUG
struct NftDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NftDetailView(nftModel: NftModel.nftStaticData[0])
            .inject(.preview)
    }
}
#endif
