//
//  String+Extension.swift
//  DreamerlyCrypto
//
//  Created by Quang Truong on 08/11/2022.
//  Copyright © 2022 Dreamerly. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func replacingRange(indexFromStart: Int, indexFromEnd: Int, replacing: String = "") -> Self {
        return self.replacingOccurrences(of: self.dropFirst(indexFromStart).dropLast(indexFromEnd), with: replacing)
    }

    func replacingRange2(indexFromStart: Int, indexFromEnd: Int, replacing: String = "") -> Self {
        return String(self.prefix(indexFromStart)) + replacing + String(self.suffix(indexFromEnd))
    }
}
