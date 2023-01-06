//
//  AppState.swift
//  CountriesSwiftUI
//
//  Created by Dreamerly on 23.10.2019.
//  Copyright © 2022 Dreamer. All rights reserved.
//

import SwiftUI
import Combine
import StoreKit
import Glaip

struct AppState: Equatable {
    var userData = UserData()
    var routing = ViewRouting()
    var system = System()
    var permissions = Permissions()
}

extension AppState {
    struct UserData: Equatable {
        @UserDefault(key: "wallet_info_model", defaultValue: nil)
        var walletInfoModel: WalletInfoModel?

        var skProducts: [SKProduct] = []

        static func == (lhs: AppState.UserData, rhs: AppState.UserData) -> Bool {
            return lhs.walletInfoModel == rhs.walletInfoModel &&
            lhs.skProducts == rhs.skProducts
        }
    }
}

extension AppState {
    struct ViewRouting: Equatable {
        var setAddress = SetAddressView.Routing()
        var login = LoginView.Routing()
        var main = MainView.Routing()
        var home = HomeView.Routing()
        var profile = ProfileView.Routing()
        var nftDetail = NftDetailView.Routing()
    }
}

extension AppState {
    struct System: Equatable {
        var isActive: Bool = false
        var keyboardHeight: CGFloat = 0
    }
}

extension AppState {
    struct Permissions: Equatable {
        var push: Permission.Status = .unknown
    }
    
    static func permissionKeyPath(for permission: Permission) -> WritableKeyPath<AppState, Permission.Status> {
        let pathToPermissions = \AppState.permissions
        switch permission {
        case .pushNotifications:
            return pathToPermissions.appending(path: \.push)
        }
    }
}

func == (lhs: AppState, rhs: AppState) -> Bool {
    return lhs.userData == rhs.userData &&
        lhs.routing == rhs.routing &&
        lhs.system == rhs.system &&
        lhs.permissions == rhs.permissions
}

#if DEBUG
extension AppState {
    static var preview: AppState {
        var state = AppState()
        state.system.isActive = true
        return state
    }
}
#endif
