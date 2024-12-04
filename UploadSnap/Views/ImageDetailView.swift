//
//  ImageDetailView.swift
//  UploadSnap
//
//  Created by Ranjit on 04/12/24.
//

import SwiftUI

struct ImageDetailView: View {
    var image: CapturedImage

    var body: some View {
        VStack {
            if let uiImage = FileManagerHelper.loadImage(from: image.url) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                Text("Image not available")
                    .padding()
            }
            Spacer()
        }
        .navigationTitle(image.name)
    }
}

#Preview {
    ImageDetailView(image: CapturedImage())
}
