//
//  ProcessImagesState.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import Foundation
import class GameplayKit.GKState
import SwiftUI

protocol FindQRImageStateProtocol {
    func complete(qrImage: QRImage?)
    func incrementProgress()
}

class FindQRImageState: GKState, GeoTagStateType {
    public let stateDisplayName = "ProcessImages"
    private let list: [FileItem]
    private let delegate: FindQRImageStateProtocol?
    private let imageProcessor = ImageProcessor()
    private var qrImage: QRImage?
    private var cancelRequested = false
    
    init(list: [FileItem], delegate: FindQRImageStateProtocol?) {
        self.list = list
        self.delegate = delegate
    }
    
    override func didEnter(from previousState: GKState?) {
        findQRImage(list: list)
    }
    
    override func willExit(to nextState: GKState) {
        if let geoTagsState = nextState as? GeoTagsStateProtocol {
            geoTagsState.setQRImage(qrImage)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    func cancel() {
        cancelRequested = true
    }
    
    private func findQRImage(list: [FileItem]) {
        let group = DispatchGroup()
        var foundQR: QRImage?
        
        group.enter()
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            var index = 0
            for item in list where foundQR == nil && strongSelf.cancelRequested == false {
                if let qr = strongSelf.imageProcessor.processImage(name: item.url) {
                    foundQR = qr
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.delegate?.incrementProgress()
                }
                index = index + 1
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {

                if strongSelf.cancelRequested {
                    foundQR = nil
                }

                strongSelf.qrImage = foundQR
                strongSelf.delegate?.complete(qrImage: foundQR)
            }
        }
    }
}

