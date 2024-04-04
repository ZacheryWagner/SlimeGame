//
//  GameState.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation

enum GameState {
    case uninitialized
    case loading
    case ready
    case playing
    case paused
    case ended
}

enum GameEvent {
    case playableAreaSetupComplete(CGRect, CGPoint)
    case boardVisualizationComplete([[Slime?]])
    case slimesUpdated([[Slime?]])
}
