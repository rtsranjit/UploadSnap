//
//  UIData+Extensions.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
