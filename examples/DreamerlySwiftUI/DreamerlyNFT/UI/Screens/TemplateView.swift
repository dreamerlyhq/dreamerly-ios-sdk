//
//  TemplateView.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 02/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import SwiftUI
import Combine
import Glaip

// MARK: - Routing
extension TemplateView {
    struct Routing: Equatable {
    }
}

// MARK: - TemplateView
struct TemplateView: View {

    // MARK: - States

    @State private var routingState: Routing = .init()
    @State private(set) var data: Loadable<Void>

    // MARK: - Binding

//    private var routingBinding: Binding<Routing> {
//        $routingState.dispatched(to: injected.appState, \.routing.home)
//    }

    // MARK: - Environment

    @Environment(\.injected) private var injected: DIContainer

    init(data: Loadable<Void> = .notRequested) {
        self._data = .init(initialValue: data)
    }

    var body: some View {
        NavigationStack {
            self.content
                .navigationTitle("Home View")
                .toolbar(.hidden)
        }
//        .onReceive(routingUpdate) { self.routingState = $0 }
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
            Text("Hello World")
                .font(.system(size: 18, weight: .semibold))
        }
        .padding([.leading, .trailing], 16)
    }
}

// MARK: - State Updates
private extension TemplateView {
//    var routingUpdate: AnyPublisher<Routing, Never> {
//        injected.appState.updates(for: \.routing.home)
//    }
}

#if DEBUG
struct TemplateView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateView(data: .loaded(()))
            .inject(.preview)
    }
}
#endif
