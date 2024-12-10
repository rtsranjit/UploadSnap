//
//  CapturedImagesListView.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import SwiftUI

struct CapturedImagesListView: View {
    @EnvironmentObject var capturedImagesVM: CapturedImagesViewModel
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var showActionSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if capturedImagesVM.capturedImages.isEmpty {
                    Text("Click on plus icon to add images")
                        .padding()
                } else {
                    List(capturedImagesVM.capturedImages) { image in
                        if let index = capturedImagesVM.capturedImages.firstIndex(where: { $0.id == image.id }) {
                            CapturedImageRow(capturedImagesVM: capturedImagesVM, image: $capturedImagesVM.capturedImages[index])
                        }
                        
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Captured Images")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showActionSheet.toggle()
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .actionSheet(isPresented: $showActionSheet) {
                ActionSheet(
                    title: Text("Choose Image Source"),
                    buttons: [
                        .default(Text("Use Camera")) {
                            imageSource = .camera
                            showImagePicker = true
                        },
                        .default(Text("Use Photo Library")) {
                            imageSource = .photoLibrary
                            showImagePicker = true
                        },
                        .cancel() // Option to cancel
                    ]
                )
            }
            .padding()
            .onAppear {
                capturedImagesVM.requestNotificationPermission()
                capturedImagesVM.fetchCapturedImages()
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imageSource) { image in
                    if let selectedImage = image {
                        capturedImagesVM.captureImage(image: selectedImage)
                    }
                }
            }
        }
    }
    
}


