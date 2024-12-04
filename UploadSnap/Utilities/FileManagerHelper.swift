//
//  FileManagerHelper.swift
//  UploadSnap
//
//  Created by Ranjit on 04/12/24.
//

import UIKit

class FileManagerHelper {
    static func loadImage(from urlString: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Documents directory not found")
            return nil
        }

        let fileURL = documentsDirectory.appendingPathComponent(urlString)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File does not exist at path: \(fileURL.path)")
            return nil
        }
        
        return UIImage(contentsOfFile: fileURL.path)
    }
}
