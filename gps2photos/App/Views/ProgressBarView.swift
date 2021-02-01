//
//  ProgressBarView.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import SwiftUI

// from: https://www.simpleswiftguide.com/how-to-build-linear-progress-bar-in-swiftui/
struct ProgressBar: View {
//    var value: Float
//    @Binding var progress: ProgressModel
    @ObservedObject var progressModel: ProgressModel
    
    var body: some View {
        Text(progressModel.taskName)
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(NSColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(progressModel.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(NSColor.systemBlue))
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}
