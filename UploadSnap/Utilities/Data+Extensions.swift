//
//  Data+Extensions.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import Foundation

extension Data {
    /// Appends a string to the `Data` instance.
    /// - Parameter string: The string to be appended.
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
