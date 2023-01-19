//
//  AppEnvironment.swift
//  CountriesSwiftUI
//
//  Created by Dreamerly on 09.11.2019.
//  Copyright © 2022 Dreamer. All rights reserved.
//

import UIKit
import Combine
import DreamerlySdk

struct AppEnvironment {
    let container: DIContainer
    let systemEventsHandler: SystemEventsHandler
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        /*
         To see the deep linking in action:
         
         1. Launch the app in iOS 13.4 simulator (or newer)
         2. Subscribe on Push Notifications with "Allow Push" button
         3. Minimize the app
         4. Drag & drop "push_with_deeplink.apns" into the Simulator window
         5. Tap on the push notification
         
         Alternatively, just copy the code below before the "return" and launch:
         
            DispatchQueue.main.async {
                deepLinksHandler.open(deepLink: .showCountryFlag(alpha3Code: "AFG"))
            }
        */
        let session = configuredURLSession()
        let interactors = configuredInteractors(appState: appState)
        let diContainer = DIContainer(appState: appState, interactors: interactors)
        let systemEventsHandler = RealSystemEventsHandler(container: diContainer)
        return AppEnvironment(container: diContainer,
                              systemEventsHandler: systemEventsHandler)
    }

    private static func configuredURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        configuration.waitsForConnectivity = true
        configuration.httpMaximumConnectionsPerHost = 5
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = .shared
        return URLSession(configuration: configuration)
    }
    
    private static func configuredInteractors(appState: Store<AppState>) -> DIContainer.Interactors {
        let userPermissionsInteractor = RealUserPermissionsInteractor(
            appState: appState,
            openAppSettings: {
                URL(string: UIApplication.openSettingsURLString).flatMap {
                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
                }
            })

//        let storeInteractor = RealStoreInteractor(appState: appState)
        let storeInteractor = RealStoreInteractor()

        return .init(userPermissionsInteractor: userPermissionsInteractor,
                     storeInteractor: storeInteractor)
    }
}
