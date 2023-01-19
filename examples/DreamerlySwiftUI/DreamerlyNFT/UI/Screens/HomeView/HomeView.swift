//
//  HomeView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
import Glaip
import StoreKit
import Amplify

// MARK: - Routing
extension HomeView {
    struct Routing: Equatable {
    }
}

// MARK: - HomeView
struct HomeView: View {

    // MARK: - States

    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<[NftModel]>
    @State private(set) var isShowingError: Bool = true

    // MARK: - Binding

    private var routingBinding: Binding<Routing> {
        $routingState.dispatched(to: injected.appState, \.routing.home)
    }

    // MARK: - Environment

    @Environment(\.injected) private var injected: DIContainer

    private let cancelBag = CancelBag()

    init(data: Loadable<[NftModel]> = .notRequested) {
        self._data = .init(initialValue: data)
        UITableView.appearance().sectionHeaderTopPadding = 0
        UITableViewCell.appearance().selectionStyle = .none
    }

    var body: some View {
        ZStack(alignment: .top) {
            self.content
                .refreshable {
                    fetchData()
                }
        }
        .onReceive(routingUpdate) { self.routingState = $0 }
    }

    // MARK: - Loading Status

    @ViewBuilder private var content: some View {
        switch data {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case .loaded(let data):
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

    func loadedView(_ data: [NftModel]) -> some View {
        ZStack {
            List {
                Section {
                    ForEach(data, id: \.id) { model in
                        ZStack {
                            VStack(spacing: 0) {
                                NftItemView(model: model)

                                Divider()
                                    .padding([.top, .bottom], 12)
                            }

                            NavigationLink(value: model, label: {
                                Rectangle().opacity(0)
                            })
                            .opacity(0)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    EmptyView()
                }
                .listRowBackground(Color.white)
                .listSectionSeparator(.hidden)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .id(data.count)
            .navigationDestination(for: NftModel.self) { model in
                NftDetailView(nftModel: model)
                    .inject(injected)
            }
        }
    }
}

// MARK: - Side Effect
private extension HomeView {
    private func fetchData() {
        data = .loaded(NftModel.nftStaticData)
        
    }
}

// MARK: - State Updates
private extension HomeView {
    var routingUpdate: AnyPublisher<Routing, Never> {
        injected.appState.updates(for: \.routing.home)
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(data: .loaded(NftModel.nftStaticData))
                .inject(.preview)
        }
    }
}
#endif
