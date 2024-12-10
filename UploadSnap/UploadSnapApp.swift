//
//  UploadSnapApp.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import SwiftUI

@main
struct UploadSnapApp: SwiftUI.App {
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = CapturedImagesViewModel()
    
    init() {
        UNUserNotificationCenter.current().delegate = NotificationHandler.shared
    }
    
    var body: some Scene {
        WindowGroup {
            CapturedImagesListView()
                .environmentObject(viewModel) // Inject ViewModel into environment
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        // Call the updateFailedImagesStatus method when the app becomes active
                        viewModel.updateFailedImagesStatus()
                    }
                }
        }
    }
}
