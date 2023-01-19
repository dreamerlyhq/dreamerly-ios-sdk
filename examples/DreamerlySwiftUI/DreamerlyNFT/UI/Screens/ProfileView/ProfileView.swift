//
//  ProfileView.swift
//  DreamerlyCrypto
//
//  Created by Quang on 07/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
import DreamerlySdk

// MARK: - Routing
extension ProfileView {
    struct Routing: Equatable {
    }
}

// MARK: - ProfileView
struct ProfileView: View {

    // MARK: - States

    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<[NftModel]>
    @State private(set) var walletInfoModel: WalletInfoModel?
    @State private(set) var isPresentAlertCopiedToClipboard = false
    @State private(set) var isShowingLoginScreen: Bool = false
    @State private(set) var isShowingSetAddressScreen: Bool = false

    @ObservedObject private var glaip: Glaip

    // MARK: - Binding

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.profile)
    }

    // MARK: - Environment

    @Environment(\.injected) private var injected: DIContainer

    private let cancelBag = CancelBag()

    init(data: Loadable<[NftModel]> = .notRequested) {
        self._data = .init(initialValue: data)
        UITableView.appearance().sectionHeaderTopPadding = 0
        UITableView.appearance().backgroundColor = UIColor.clear

        self.glaip = Glaip(
            title: "Dreamerly",
            description: "Dreamerly",
            clientUrl: "https://dreamerly.com",
            supportedWallets: [.Rainbow, .TrustWallet])
    }

    var body: some View {
        ZStack(alignment: .top) {
            if walletInfoModel != nil {
                self.content
            } else {
                LoginStatusView(buttonTitle: "Connect with wallet app", title: "Profile",
                                subtitle: "To browse the NFTs in your collection, please enter your wallet address, or connect with your wallet app.",
                                buttonAction: showLoginView, buttonActionSetAddress: showSetAddressView)
            }
        }
        .background(Color.white)
        .onReceive(routingUpdate) { self.routingState = $0 }
        .onReceive(walletInfoModelUpdate) { self.walletInfoModel = $0 }
        .alert("Copied to Clipboard", isPresented: $isPresentAlertCopiedToClipboard) {
            EmptyView()
        }
        .sheet(isPresented: $isShowingLoginScreen) {
            LoginView(data: .loaded(()), glaip: glaip, isShowingLoginScreen: $isShowingLoginScreen)
        }
        .sheet(isPresented: $isShowingSetAddressScreen) {
            SetAddressView(data: .loaded(()), isShowingSetAddressScreen: $isShowingSetAddressScreen)
        }
    }

    // MARK: - Loading Status

    @ViewBuilder private var content: some View {
        switch data {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case let .loaded(data):
            loadedView(data)
        case let .failed(error):
            failedView(error)
        }
    }

    var notRequestedView: some View {
        Text("")
            .onAppear {
                fetchData()
            }
    }

    func loadingView(_ previouslyLoaded: [NftModel]?) -> some View {
        if let data = previouslyLoaded {
            return AnyView(loadedView(data))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }

    func failedView(_ error: Error) -> some View {
        ErrorView(error: error, retryAction: {
            // TODO: Reload Actions
        })
    }

    func loadedView(_ data: [NftModel]) -> some View {
        List {
            Section {
                VStack(spacing: 24) {
                    if data.isEmpty {
                        EmptyDataView(buttonTitle: "Explore NFTs") {
                            injected.appState.bulkUpdate { state in
//                                state.routing.main.selectedTabBar = .home
                            }
                        }
                    } else {
//                        ForEach(data, id: \.id) { model in
//                            ZStack {
//                                MyNftItemView(model: model)
//
//                                NavigationLink(value: model, label: {
//                                    Rectangle().opacity(0)
//                                })
//                                .opacity(0)
//                            }
//                        }
                    }
                }
            } header: {
                VStack(alignment: .center, spacing: 16) {
                    Image("avatar")
                        .frame(width: 64, height: 64)
                    Text("Unnamed")
                        .font(.system(size: 18, weight: .semibold))

                    HStack(spacing: 8) {
                        Text(walletInfoModel?.address.replacingRange(indexFromStart: 6, indexFromEnd: 6, replacing: "...") ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#58585A"))

                        Button {
                            UIPasteboard.general.string = walletInfoModel?.address ?? ""
                            isPresentAlertCopiedToClipboard.toggle()
                        } label: {
                            Image("copy-icon")
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding([.leading, .trailing], 40)

                    if !data.isEmpty {
                        Text("Transactions")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .listSectionSeparator(.hidden)
            .listRowSeparator((.hidden))
            .listRowBackground(Color.white)
        }
        .id(data.count)
        .listStyle(.grouped)
        .background(Color.white.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .navigationDestination(for: NftModel.self) { model in
            NftDetailView(nftModel: model)
                .inject(injected)
        }
    }
}

// MARK: - Side Effect
private extension ProfileView {
    private func showLoginView() {
        print("QQ: Present Login View")
        isShowingLoginScreen.toggle()
    }
    
    private func showSetAddressView() {
        print("QQ: Present Set Address View")
        isShowingSetAddressScreen.toggle()
    }
    
    private func fetchData() {

        data = .loaded(NftModel.nftStaticData)
        
    }
}

// MARK: - State Updates
private extension ProfileView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.profile)
    }

    var walletInfoModelUpdate: AnyPublisher<WalletInfoModel?, Never> {
        injected.appState.updates(for: \.userData.walletInfoModel?)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView(data: .loaded(NftModel.nftStaticData))
                .inject(.preview)
        }
    }
}
#endif
