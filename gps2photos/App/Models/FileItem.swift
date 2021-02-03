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

    public func date() -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: url.path))?[.creationDate] as? Date
    }
}
