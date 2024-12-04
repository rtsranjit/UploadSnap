//
//  CapturedImageRow.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import SwiftUI

struct CapturedImageRow: View {
    
    @ObservedObject var capturedImagesVM: CapturedImagesViewModel
    
    @Binding var image: CapturedImage
    
    var body: some View {
        ZStack {
            
            NavigationLink(destination: ImageDetailView(image: image)) {
                EmptyView()
            }
            .opacity(0)

            HStack {
                if let uiImage = FileManagerHelper.loadImage(from: image.url) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text(image.name)
                        .font(.headline)
                    Text(image.uploadStatus)
                        .font(.subheadline)
                }
                
                Spacer()
                
                if image.uploadStatus == UploadStatus.completed.rawValue {
                    Text("Uploaded")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Color.green.cornerRadius(5)
                        }
                } else if image.uploadStatus == UploadStatus.uploading.rawValue {
                    UploadProgressView(progress: image.uploadProgress)
                        .frame(width: 45, height: 45)
                } else {
                    Text((image.uploadStatus == UploadStatus.failed.rawValue) ? "Reupload" : "Upload")
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Color.blue.cornerRadius(5)
                        }
                        .onTapGesture {
                            if let uIImage = FileManagerHelper.loadImage(from: image.url) {
                                capturedImagesVM.uploadImage(uiImage: uIImage, imageName: image.name)
                            }
                        }
                        .padding(.leading, 8)
                }
            }
        }
    }
}


//struct CapturedImageRow_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleImage = CapturedImage()
//
//        CapturedImageRow(capturedImagesVM: CapturedImagesViewModel(), image: .constant(sampleImage))
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}
