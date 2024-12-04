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
    private var imageUploader: ImageUploader?
    
    init() {
        
        do {
            realm = try Realm()
        } catch {
            print("Error initializing Realm: \(error.localizedDescription)")
            fatalError("Realm could not be initialized")
        }
        
        fetchCapturedImages()
    }
    
    func fetchCapturedImages() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let images = self.realm.objects(CapturedImage.self)
            self.capturedImages = Array(images)
        }
    }
    
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
        newImage.url = fileName // Store the file path in the url property
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
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            self.imageUploader = ImageUploader(viewModel: self)
//            self.imageUploader?.uploadImage(image: image, imageName: newImage.name)
//        }
    }
    
    func uploadImage(uiImage: UIImage, imageName: String) {
        if let image = capturedImages.first(where: { $0.name == imageName }) {
            self.imageUploader = ImageUploader(viewModel: self)
            self.imageUploader?.uploadImage(image: uiImage, imageName: image.name)
        }
    }
    
    func associateTask(_ task: URLSessionTask, withImageNamed imageName: String, progress: Double) {
        do {
            try realm.write {
                if let image = capturedImages.first(where: { $0.name == imageName }) {
                    image.uploadStatus = UploadStatus.uploading.rawValue
                    image.uploadProgress = progress
                    
                    if image.uploadProgress == 1 {
                        image.uploadStatus = UploadStatus.completed.rawValue
                        self.scheduleNotification(for: imageName)
                    }
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.capturedImages = Array(self.realm.objects(CapturedImage.self))
            }
        } catch {
            print("Error saving image metadata to Realm: \(error.localizedDescription)")
        }
    }
    
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

