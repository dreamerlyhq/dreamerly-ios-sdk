//
//  Helpers.swift
//  CountriesSwiftUI
//
//  Created by Dreamerly on 10.11.2019.
//  Copyright © 2022 Dreamer. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - General

extension ProcessInfo {
    var isRunningTests: Bool {
        return false
    }
}

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

// MARK: - View Inspection helper

internal final class Inspection<V> {
    let notice = PassthroughSubject<UInt, Never>()
    var callbacks = [UInt: (V) -> Void]()
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}
