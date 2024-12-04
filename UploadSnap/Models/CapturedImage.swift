//
//  CapturedImage.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import Foundation
import RealmSwift

// CapturedImage Model
class CapturedImage: Object, Identifiable {
    @objc dynamic var id = UUID().uuidString // Ensure `id` is unique
    @objc dynamic var name = ""
    @objc dynamic var imageData = Data() // Ensure this is a valid data format
    @objc dynamic var url: String = ""
    @objc dynamic var uploadStatus: String = UploadStatus.pending.rawValue
    @objc dynamic var uploadProgress: Double = 0.0
}

// Enum for upload status
enum UploadStatus: String {
    case pending = "Pending"
    case uploading = "Uploading"
    case completed = "Completed"
    case failed = "Failed"
}
