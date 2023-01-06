//
//  DIContainer.Interactors.swift
//  CountriesSwiftUI
//
//  Created by Dreamerly on 24.10.2019.
//  Copyright © 2022 Dreamer. All rights reserved.
//

import DreamerlySdk

extension DIContainer {
    struct Interactors {
        let userPermissionsInteractor: UserPermissionsInteractor
        let storeInteractor: StoreInteractor

        init(userPermissionsInteractor: UserPermissionsInteractor,
             storeInteractor: StoreInteractor) {
            self.userPermissionsInteractor = userPermissionsInteractor
            self.storeInteractor = storeInteractor
        }

        static var stub: Self {
            .init(userPermissionsInteractor: StubUserPermissionsInteractor(),
                  storeInteractor: StubStoreInteractor())
        }
    }
}
