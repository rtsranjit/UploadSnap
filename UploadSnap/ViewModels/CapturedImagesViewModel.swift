//
//  CapturedImagesViewModel.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import Foundation
import RealmSwift
import UIKit
import UserNotifications

class CapturedImagesViewModel: ObservableObject {
    @Published var capturedImages: [CapturedImage] = []
    private var realm: Realm
    private let uploader = ImageUploader()

    init() {
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
            fatalError("Realm could not be initialized")
        }
        fetchCapturedImages()
        requestNotificationPermission()
    }

    // MARK: - Data Fetching

    /// Fetches all captured images from Realm.
    func fetchCapturedImages() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let images = self.realm.objects(CapturedImage.self)
            self.capturedImages = Array(images)
        }
    }

    // MARK: - Image Capture

    /// Saves the captured image locally and adds metadata to Realm.
    func captureImage(image: UIImage) {
        let newImage = CapturedImage()
        let fileName = newImage.id + ".jpg"

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not access the documents directory.")
            return
        }

        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Could not convert image to JPEG data.")
            return
        }

        do {
            try imageData.write(to: fileURL)
            print("Image saved to: \(fileURL.path)")
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return
        }

        newImage.name = "Image \(capturedImages.count + 1)"
        newImage.url = fileName
        newImage.uploadStatus = UploadStatus.pending.rawValue
        newImage.uploadProgress = 0.0

        do {
            try realm.write {
                realm.add(newImage)
            }
            print("Image metadata saved to Realm.")
        } catch {
            print("Error saving image metadata to Realm: \(error.localizedDescription)")
        }

        fetchCapturedImages()
    }

    // MARK: - Upload Handling

    /// Uploads an image to the server and tracks its progress.
    func uploadImage(image: UIImage, imageName: String) {
        guard let capturedImage = capturedImages.first(where: { $0.name == imageName }),
              capturedImage.uploadStatus != UploadStatus.uploading.rawValue else {
            print("Upload already in progress for \(imageName).")
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Error: Unable to convert image to data.")
            return
        }

        guard let uploadURL = URL(string: "https://www.clippr.ai/api/upload") else {
            print("Error: Invalid upload URL.")
            return
        }

        updateUploadStatus(for: imageName, status: .uploading)

        uploader.uploadFile(
            with: uploadURL,
            fileData: imageData,
            fileName: imageName,
            fileType: "image/jpeg",
            onProgress: { [weak self] progress in
                self?.updateUploadProgress(for: imageName, progress: progress)
            },
            onComplete: { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.updateUploadStatus(for: imageName, status: .completed)
                        self?.scheduleNotification(for: imageName)
                    case .failure(let error):
                        print("Upload failed: \(error.localizedDescription)")
                        self?.updateUploadStatus(for: imageName, status: .failed)
                    }
                }
            }
        )
    }

    /// Updates the upload progress in Realm.
    private func updateUploadProgress(for imageName: String, progress: Double) {
        do {
            try realm.write {
                if let image = capturedImages.first(where: { $0.name == imageName }) {
                    image.uploadStatus = UploadStatus.uploading.rawValue
                    image.uploadProgress = progress
                }
            }
            refreshCapturedImages()
        } catch {
            print("Error updating upload progress: \(error.localizedDescription)")
        }
    }

    /// Updates the upload status in Realm.
    private func updateUploadStatus(for imageName: String, status: UploadStatus) {
        do {
            try realm.write {
                if let image = capturedImages.first(where: { $0.name == imageName }) {
                    image.uploadStatus = status.rawValue
                    if status == .completed {
                        image.uploadProgress = 1.0
                    }
                }
            }
            refreshCapturedImages()
        } catch {
            print("Error updating upload status: \(error.localizedDescription)")
        }
    }

    /// Refreshes the captured images array from Realm.
    private func refreshCapturedImages() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.capturedImages = Array(self.realm.objects(CapturedImage.self))
        }
    }

    // MARK: - Notifications

    /// Schedules a local notification after successful upload.
    private func scheduleNotification(for imageName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Upload Complete"
        content.body = "The upload for \(imageName) has been successfully completed."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    /// Requests permission for local notifications.
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}
