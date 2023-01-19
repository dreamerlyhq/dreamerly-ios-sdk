//
//  LoginView.swift
//  DreamerlyCrypto
//
//  Created by Quang on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
//import Glaip
import DreamerlySdk

// MARK: - Routing
extension LoginView {
    struct Routing: Equatable {
    }
}

// MARK: - LoginView
struct LoginView: View {
    
    // MARK: - ObservedObject

    @ObservedObject private var glaip: Glaip
    
    // MARK: - States

    @Binding var isShowingLoginScreen: Bool
    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<Void>
    @State private var walletAddress: String = ""
    @State private var chainId: String = ""

//    @Environment(\.dismiss) var dismiss

    // MARK: - Binding

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.login)
    }

    // MARK: - Environment

    @Environment(\.injected) private var injected: DIContainer

    init(data: Loadable<Void>, glaip: Glaip, isShowingLoginScreen: Binding<Bool>) {
        self._data = .init(initialValue: data)
        self.glaip = glaip
        self._isShowingLoginScreen = isShowingLoginScreen
    }

    var body: some View {
        self.content
            .onReceive(routingUpdate) { self.routingState = $0 }
    }

    // MARK: - Loading Status

    @ViewBuilder private var content: some View {
        switch data {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case .loaded:
//            LoginViewSdk(loginWith: loginWith)
            loadedView()
        case let .failed(error):
            failedView(error)
        }
    }

    var notRequestedView: some View {
        Text("")
            .onAppear {
                // TODO: Call API Reload Data
            }
    }

    func loadingView(_ previouslyLoaded: Void?) -> some View {
        if let _ = previouslyLoaded {
            return AnyView(loadedView())
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            // TODO: Reload Actions
        })
    }

    func loadedView() -> some View {
        VStack(spacing: 24) {
            
            Text("Connect with your wallet app.")
                .font(.system(size: 18, weight: .semibold))

            Text("Per the App Store's policy, we do not facilitate virtual currency transmission.")
                .font(.system(size: 14))

            VStack(alignment: .center, spacing: 0) {
                WalletButtonView(
                    title: "MetaMask",
                    action: {
                        loginWith(.MetaMask)
                    },
                    iconImage: Image("metamask-icon")
                )

                Divider()

                WalletButtonView(
                    title: "Trust Wallet",
                    action: {
                        loginWith(.TrustWallet)
                    },
                    iconImage: Image("trustwallet-icon")
                )

                Divider()

                WalletButtonView(
                    title: "Rainbow",
                    action: {
                        loginWith(.Rainbow)
                    },
                    iconImage: Image("rainbow-icon")
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("Greyscale-G3"), lineWidth: 1)
            )
        }
        .padding([.leading, .trailing], 16)
    }
}

// MARK: - Side Effects

extension LoginView {
    private func loginWith(_ walletType: WalletType) {
        glaip.loginUser(type: walletType) { result in
            switch result {
            case .success(let user):
                print(user.wallet.address)
                let walletInfoModel = WalletInfoModel(address: user.wallet.address,
                                                      chainId: user.wallet.chainId)
                injected.appState[\.userData.walletInfoModel] = walletInfoModel
                isShowingLoginScreen.toggle()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setDeliverWallet(address: String, chainId: String) {
        let walletInfoModel = WalletInfoModel(address: address,
                                              chainId: chainId)
        injected.appState[\.userData.walletInfoModel] = walletInfoModel
        isShowingLoginScreen.toggle()
    }
}

// MARK: - State Updates
private extension LoginView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.login)
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static let glaip: Glaip = Glaip(
        title: "Dreamerly",
        description: "Dreamerly NFT",
        clientUrl: "https://dreamerly.com",
        supportedWallets: [.Rainbow, .TrustWallet])

    static var previews: some View {
        LoginView(data: .loaded(()), glaip: glaip, isShowingLoginScreen: .constant(true))
            .inject(.preview)
    }
}
#endif

//// MARK: - Routing
//extension LoginView {
//    struct Routing: Equatable {
//    }
//}
//
//// MARK: - LoginView
//struct LoginView: View {
//
//    // MARK: - ObservedObject
//
//    @ObservedObject private var glaip: Glaip
//
//    // MARK: - States
//
//    @Binding var isShowingLoginScreen: Bool
//    @State private var routingState: Routing = .init()
//    @State private(set) var data: Loadable<Void>
//
////    @Environment(\.dismiss) var dismiss
//
//    // MARK: - Binding
//
//    private var routingBinding: Binding<Routing> {
//        $routingState.dispatched(to: injected.appState, \.routing.login)
//    }
//
//    // MARK: - Environment
//
//    @Environment(\.injected) private var injected: DIContainer
//
//    init(data: Loadable<Void>, glaip: Glaip, isShowingLoginScreen: Binding<Bool>) {
//        self._data = .init(initialValue: data)
//        self.glaip = glaip
//        self._isShowingLoginScreen = isShowingLoginScreen
//    }
//
//    var body: some View {
//        self.content
//            .onReceive(routingUpdate) { self.routingState = $0 }
//    }
//
//    // MARK: - Loading Status
//
//    @ViewBuilder private var content: some View {
//        switch data {
//        case .notRequested:
//            notRequestedView
//        case let .isLoading(last, _):
//            loadingView(last)
//        case .loaded:
//            loadedView()
//        case let .failed(error):
//            failedView(error)
//        }
//    }
//
//    var notRequestedView: some View {
//        Text("")
//            .onAppear {
//                // TODO: Call API Reload Data
//            }
//    }
//
//    func loadingView(_ previouslyLoaded: Void?) -> some View {
//        if let _ = previouslyLoaded {
//            return AnyView(loadedView())
//        } else {
//            return AnyView(ActivityIndicatorView().padding())
//        }
//    }
//
//    func failedView(_ error: Error) -> some View {
//        ErrorView(error: error, retryAction: {
//            // TODO: Reload Actions
//        })
//    }
//
//    func loadedView() -> some View {
//        VStack(spacing: 24) {
//            Text("Connect with wallet")
//                .font(.system(size: 18, weight: .semibold))
//
//            Text("After you purchase NFTs via in-app purchases, NFTs and digital goods will be sent to your wallet. Per the App Store's policy, we do not facilitate virtual currency transmission.")
//                .font(.system(size: 14))
//
//            VStack(alignment: .center, spacing: 0) {
//                WalletButtonView(
//                    title: "MetaMask",
//                    action: {
//                        loginWith(.MetaMask)
//                    },
//                    iconImage: Image("metamask-icon")
//                )
//
//                Divider()
//
//                WalletButtonView(
//                    title: "Trust Wallet",
//                    action: {
//                        loginWith(.TrustWallet)
//                    },
//                    iconImage: Image("trustwallet-icon")
//                )
//
//                Divider()
//
//                WalletButtonView(
//                    title: "Rainbow",
//                    action: {
//                        loginWith(.Rainbow)
//                    },
//                    iconImage: Image("rainbow-icon")
//                )
//            }
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color("Greyscale-G3"), lineWidth: 1)
//            )
//        }
//        .padding([.leading, .trailing], 16)
//    }
//}
//
//// MARK: - Side Effects
//
//extension LoginView {
//    private func loginWith(_ walletType: WalletType) {
//        glaip.loginUser(type: walletType) { result in
//            switch result {
//            case .success(let user):
//                print(user.wallet.address)
//                let walletInfoModel = WalletInfoModel(address: user.wallet.address,
//                                                      chainId: user.wallet.chainId)
//                injected.appState[\.userData.walletInfoModel] = walletInfoModel
//                isShowingLoginScreen.toggle()
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
//
//// MARK: - State Updates
//private extension LoginView {
//    var routingUpdate: AnyPublisher<Routing, Never> {
//        injected.appState.updates(for: \.routing.login)
//    }
//}
//
//#if DEBUG
//struct LoginView_Previews: PreviewProvider {
//    static let glaip: Glaip = Glaip(
//        title: "Dreamerly",
//        description: "Dreamerly NFT",
//        clientUrl: "https://dreamerly.com",
//        supportedWallets: [.Rainbow, .TrustWallet])
//
//    static var previews: some View {
//        LoginView(data: .loaded(()), glaip: glaip, isShowingLoginScreen: .constant(true))
//            .inject(.preview)
//    }
//}
//#endif
