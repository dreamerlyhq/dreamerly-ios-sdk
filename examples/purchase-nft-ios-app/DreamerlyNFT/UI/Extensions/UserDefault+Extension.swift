//
//  UserDefault+Extension.swift
//  DreamerlyCrypto
//
//  Created by Quang on 05/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

@propertyWrapper
struct UserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T

    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
