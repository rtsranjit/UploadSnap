//
//  ImageUploader.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import Foundation
import UIKit

class ImageUploader: NSObject, URLSessionDelegate {
    private var session: URLSession
    private var progressObserver: NSKeyValueObservation?

    // MARK: - Initialization

    override init() {
        self.session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        super.init()
    }

    // MARK: - Upload Functionality

    /// Uploads a file to the server using a multipart request.
    /// - Parameters:
    ///   - url: Server endpoint URL.
    ///   - fileData: File data to be uploaded.
    ///   - fileName: Name of the file.
    ///   - fileType: MIME type of the file.
    ///   - fieldName: Field name in the multipart request (default: "image").
    ///   - onProgress: Callback for upload progress.
    ///   - onComplete: Callback for completion with success or failure.
    func uploadFile(
        with url: URL,
        fileData: Data,
        fileName: String,
        fileType: String,
        fieldName: String = "image",
        onProgress: @escaping (Double) -> Void,
        onComplete: @escaping (Result<Data, Error>) -> Void
    ) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Create multipart form body
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(fileType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n")

        // Setup upload task
        let uploadTask = session.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                onComplete(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCodeError = NSError(
                    domain: "UploadError",
                    code: (response as? HTTPURLResponse)?.statusCode ?? 0,
                    userInfo: nil
                )
                onComplete(.failure(statusCodeError))
                return
            }

            onComplete(.success(data ?? Data()))
        }

        // Observe progress updates
        progressObserver = uploadTask.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                onProgress(progress.fractionCompleted)
            }
        }

        uploadTask.resume()
    }
}
