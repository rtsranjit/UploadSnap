//
//  ImageUploader.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import Foundation
import RealmSwift
import UIKit

class ImageUploader: NSObject {
    
    private var uploadTask: URLSessionUploadTask?
    private var session: URLSession?
    private var capturedImagesVM: CapturedImagesViewModel

    init(viewModel: CapturedImagesViewModel) {
        self.capturedImagesVM = viewModel
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        super.init()
    }

    var progressObserver: NSKeyValueObservation?

    func uploadImage(image: UIImage, imageName: String) {
        
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Unable to convert image to data.")
            return
        }

        let url = URL(string: "https://www.clippr.ai/api/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")

        uploadTask = session?.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }

            // Check response status
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Upload failed with response: \(String(describing: response))")
                return
            }
            
            print("Upload successful!")
        }
        
        if let task = uploadTask {
            progressObserver = task.progress.observe(\.fractionCompleted) { progress, _ in
                DispatchQueue.main.async { [self] in
                    
                    capturedImagesVM.associateTask(task, withImageNamed: imageName, progress: progress.fractionCompleted)
                    
                    print("Upload Progress: \(progress.fractionCompleted * 100)%")
                }
            }
        }

        uploadTask?.resume()
    }

}
