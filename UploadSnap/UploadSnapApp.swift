//
//  UploadSnapApp.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import SwiftUI

@main
struct UploadSnapApp: SwiftUI.App {
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            CapturedImagesListView()
        }
    }
}

