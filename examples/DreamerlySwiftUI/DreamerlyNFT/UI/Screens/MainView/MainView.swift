//
//  MainView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 30/10/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
import Glaip

enum TabBarType: Int {
    case home = 0
    case profile
}

// MARK: - Routing
extension MainView {
    struct Routing: Equatable {
    }
}

// MARK: - HomeView
struct MainView: View {

    private let cancelBag = CancelBag()

    // MARK: - States

    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<Void>
    @State private(set) var walletInfoModel: WalletInfoModel?
    @State private(set) var selectedTabBar: TabBarType = .home
    @State private(set) var isPresentLogoutConfirmationDialog = false

    // MARK: - Binding

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.main)
    }

    // MARK: - Environment

    @Environment(\.injected) private var injected: DIContainer

    init(data: Loadable<Void> = .notRequested) {
        self._data = .init(initialValue: data)
    }

    var body: some View {
        NavigationStack {
            self.content
                .onReceive(routingUpdate) { self.routingState = $0 }
                .onReceive(walletInfoModelUpdate) { self.walletInfoModel = $0 }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if selectedTabBar == .home {
                        ToolbarItem(placement: .principal) {
                            Image("logo-with-black-text")
                        }
                    } else {
                        if walletInfoModel != nil {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    isPresentLogoutConfirmationDialog.toggle()
                                } label: {
                                    Image("logout-icon")
                                        .frame(width: 24, height: 24)
                                }
                                .confirmationDialog("Confirmation", isPresented: $isPresentLogoutConfirmationDialog) {
                                    Button(role: .destructive) {
                                        injected.appState.bulkUpdate { state in
                                            state.userData.walletInfoModel = nil
                                        }
                                    } label: {
                                        Text("Logout")
                                    }
                                } message: {
                                    Text("Do you want to logout?")
                                }
                            }
                        }

                        ToolbarItem(placement: .principal) {
                            Text("Profile")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                }
                .toolbar(.visible, for: .navigationBar)
                .tint(Color("Primary-P4"))
        }
    }

    // MARK: - Content

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
        getTabbarView()
    }

    private func getTabbarView() -> some View {
        TabView(selection: $selectedTabBar) {
            HomeView()
                .inject(injected)
                .navigationTitle("Collections")
                .tabItem {
                    Label("Home", image: "tabbar-home")
                }
                .tag(TabBarType.home)
                .id(TabBarType.home)

            ProfileView()
                .inject(injected)
                .tabItem {
                    Label("Profile", image: "tabbar-user")
                }
                .tag(TabBarType.profile)
                .id(TabBarType.profile)
        }
        .id(selectedTabBar)
    }
}

// MARK: - State Updates
private extension MainView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.main)
    }

    var walletInfoModelUpdate: AnyPublisher<WalletInfoModel?, Never> {
        injected.appState.updates(for: \.userData.walletInfoModel?)
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(data: .loaded(()))
            .inject(.preview)
    }
}
#endif
