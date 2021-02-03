//
//  StartState.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import class GameplayKit.GKState

class GeoTagInitializeState: GKState, GeoTagStateType {
    public let stateDisplayName = "Initializing"
    
    override func didEnter(from previousState: GKState?) {
        // Nothing to do here
    }
    
    override func willExit(to nextState: GKState) {
        // Nothing to do here
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    func cancel() {
        // Nothing to do here
    }
}
