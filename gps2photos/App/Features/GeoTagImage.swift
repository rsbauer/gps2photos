//
//  GeoTagImage.swift
//  gps2photos
//
//  Created by Astro on 1/29/21.
//

import Foundation
import SwiftUI

public class GeoTagImage: ObservableObject {
    @Published public var progress = ProgressModel()
    @Published public var hasQRImage = false
    @Published public var isProcessing = false
    private let imageProcessor = ImageProcessor()
    private var machine: GeoTagStateMachine?

    public func processImages(list: [FileItem], qrImage: QRImage?, gpsFile: URL?) {
        guard let gpsFile = gpsFile else {
            return
        }
        
        progress.index = 0
        progress.totalTasks = list.count * 2
        
        machine = GeoTagStateMachine(states: [
            GeoTagInitializeState(),
            FindQRImageState(list: list, delegate: self),
            GeoTagsState(list: list, gpsFile: gpsFile, delegate: self),
            CancelState()
        ])
        
        isProcessing = true
        machine?.enter(GeoTagInitializeState.self)
        progress.taskName = "Finding QR Code"
        machine?.enter(FindQRImageState.self)
    }
    
    public func cancel() {
        machine?.enter(CancelState.self)
    }
}

extension GeoTagImage: FindQRImageStateProtocol {
    func incrementProgress() {
        progress.index = progress.index + 1
    }
    
    func complete(qrImage: QRImage?) {
        if qrImage != nil {
            progress.index = progress.totalTasks / 2
            machine?.enter(GeoTagsState.self)
            progress.taskName = "Found QR Code - GeoTagging Images"
            hasQRImage = true
        }
    }
}

extension GeoTagImage: ApplyGeoTagsStateProtocol {
    func complete() {
        progress.taskName = "Done!"
        isProcessing = false
    }
    
    func incrementProgress(item: FileItem) {
        progress.index = progress.index + 1
    }
}
