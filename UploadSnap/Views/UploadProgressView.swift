//
//  UploadProgressView.swift
//  UploadSnap
//
//  Created by Ranjit on 03/12/24.
//

import SwiftUI

struct UploadProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.blue.opacity(0.5),
                    lineWidth: 5
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.blue,
                    style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
            
            Text("\(String(format: "%.0f", progress * 100))%")
                .font(.system(size: 10))

        }
    }
}

#Preview {
    UploadProgressView(progress: 0.6)
}
