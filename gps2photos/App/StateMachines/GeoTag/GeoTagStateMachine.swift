//
//  GeoTagStateMachine.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import class GameplayKit.GKStateMachine
import class GameplayKit.GKState

public protocol GeoTagStateType {
    var stateDisplayName: String { get }
    
    func cancel()
}

class GeoTagStateMachine: GKStateMachine {
    override init(states: [GKState]) {
        super.init(states: states)
    }
}
