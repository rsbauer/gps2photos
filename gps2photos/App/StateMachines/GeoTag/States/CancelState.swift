//
//  CancelState.swift
//  gps2photos
//
//  Created by Astro on 1/30/21.
//

import class GameplayKit.GKState

class CancelState: GKState, GeoTagStateType {
    public let stateDisplayName = "Initializing"
    
    override func didEnter(from previousState: GKState?) {
        if let previous = previousState as? GeoTagStateType {
            previous.cancel()
        }
    }
    
    override func willExit(to nextState: GKState) {
        // TODO
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return true
    }
    
    func cancel() {
        // Nothing to do here
    }
}
