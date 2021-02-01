//
//  GeoTagState.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import Foundation
import class GameplayKit.GKState
import SwiftUI

protocol ApplyGeoTagsStateProtocol {
    func complete()
    func incrementProgress(item: FileItem)
}

protocol GeoTagsStateProtocol {
    func setQRImage(_ image: QRImage?)
}

class GeoTagsState: GKState, GeoTagStateType {
    public let stateDisplayName = "ApplyGeoTagsState"
    private let list: [FileItem]
    private let delegate: ApplyGeoTagsStateProtocol?
    private let gpsFile: URL
    private let imageProcessor = ImageProcessor()
    private var qrImage: QRImage?
    private var cancelRequested = false

    init(list: [FileItem], gpsFile: URL, delegate: ApplyGeoTagsStateProtocol?) {
        self.list = list
        self.gpsFile = gpsFile
        self.delegate = delegate
    }
    
    override func didEnter(from previousState: GKState?) {
        processImages(fileItems: list)
    }
    
    override func willExit(to nextState: GKState) {
        // TODO
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    func cancel() {
        cancelRequested = true
    }
    
    private func processImages(fileItems: [FileItem]) {
        let group = DispatchGroup()
        
        group.enter()
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let strongSelf = self else { return }
            var index = 0
            
            for item in fileItems where strongSelf.cancelRequested == false {
                
                if strongSelf.adjustDate(using: strongSelf.qrImage, for: item.url) {
                    _ = strongSelf.geoTagImage(for: item.url, using: strongSelf.qrImage?.path)
                }
                
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.delegate?.incrementProgress(item: item)
                }
                index = index + 1
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if !strongSelf.cancelRequested {
                    strongSelf.delegate?.complete()
                }
            }
        }
    }
    
    private func adjustDate(using qr: QRImage?, for path: URL) -> Bool {
        guard let qr = qr else {
            return false
        }
        
        return imageProcessor.adjustDates(using: qr, for: path)
    }
    
    private func geoTagImage(for url: URL, using gps: URL?) -> Bool {
        guard let gpsFile = gps else {
            return false
        }
        let group = DispatchGroup()
        var result: (String?, Int32)?
        
        let exifToolCommand = "exiftool -overwrite_original -geotag="
        let command = "\(exifToolCommand)\"\(gpsFile.path)\" \"\(url.path)\""
        
        group.enter()
        DispatchQueue.global(qos: .default).async {
            result = Shell.run(command)
            group.leave()
        }
        
        group.wait()
        
        if result?.1 == 0 {
            return true
        }
        
        return false
    }
}

extension GeoTagsState: GeoTagsStateProtocol {
    func setQRImage(_ image: QRImage?) {
        qrImage = image
    }
}
