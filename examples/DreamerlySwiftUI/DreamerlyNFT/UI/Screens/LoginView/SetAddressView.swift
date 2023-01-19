//
//  LoginView.swift
//  DreamerlyCrypto
//
//  Created by Quang on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
import DreamerlySdk

// MARK: - Routing
extension SetAddressView {
    struct Routing: Equatable {
    }
}

// MARK: - LoginView
struct SetAddressView: View {
    
    // MARK: - States

    @Binding var isShowingSetAddressScreen: Bool
    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<Void>
    @State private var walletAddress: String = ""
    @State private var chainId: String = ""

//    @Environment(\.dismiss) var dismiss

    // MARK: - Binding

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.setAddress)
    }

    // MARK: - Environment

    @Environment(\.injected) private var injected: DIContainer

    init(data: Loadable<Void>, isShowingSetAddressScreen: Binding<Bool>) {
        self._data = .init(initialValue: data)
        self._isShowingSetAddressScreen = isShowingSetAddressScreen
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
            
            Text("Enter your wallet address and chain ID below.")
                .font(.system(size: 18, weight: .semibold))
            
            VStack(alignment: .center, spacing: 0) {
                TextField("Wallet address", text: $walletAddress)
                
                Divider()
                
                TextField("Chain ID", text: $chainId)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color("Black"), lineWidth: 1)
            )
            
            PrimaryButtonView(buttonTitle: "Confirm") {
                setDeliverWallet(address: walletAddress, chainId: chainId)
            }
            
            Text("Per the App Store's policy, we do not facilitate virtual currency transmission.")
                .font(.system(size: 14))
            
        }
        .padding([.leading, .trailing], 16)
    }
}

// MARK: - Side Effects

extension SetAddressView {
    private func setDeliverWallet(address: String, chainId: String) {
        let walletInfoModel = WalletInfoModel(address: address,
                                              chainId: chainId)
        injected.appState[\.userData.walletInfoModel] = walletInfoModel
        isShowingSetAddressScreen.toggle()
    }
}

// MARK: - State Updates
private extension SetAddressView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.setAddress)
    }
}

#if DEBUG
struct SetAddressView_Previews: PreviewProvider {

    static var previews: some View {
        SetAddressView(data: .loaded(()), isShowingSetAddressScreen: .constant(true))
            .inject(.preview)
    }
}
#endif
