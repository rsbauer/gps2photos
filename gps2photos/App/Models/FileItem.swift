//
//  FileItemModel.swift
//  gps2photos
//
//  Created by Astro on 1/26/21.
//

import Foundation
import SwiftUI

public struct FileItem: Hashable, Equatable {
    public let url: URL
    // This needs to be cleaned up!  DateFormatter shouldn't be here!

    private func dateFromFile() -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.creationDate] as? Date
    }
    
    public func date() -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.creationDate] as? Date
    }
}
