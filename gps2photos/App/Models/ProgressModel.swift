//
//  ProgressModel.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import SwiftUI

public class ProgressModel: ObservableObject {
    @Published public var index = 0
    @Published public var totalTasks = 0
    
    public var value: Float {
        Float(index) / Float(totalTasks > 0 ? totalTasks : 1)
    }

    @Published public var taskName = ""
}

