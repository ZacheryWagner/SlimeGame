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
    /// The scene has finished loading textures and setting up the world
    case playableAreaSetupComplete(CGRect, CGPoint)

    /// The board has generated the slimes an assigned their positions
    case boardVisualizationComplete([[Slime?]])

    /// There has been a completed swipe action on a given row or column
    case swipe(Direction, Int)

    /// The slimes have finished moving to their new place
    case slimesFinishedMovement

    /// Line(s) have been succesfully completed durring the game loop
    case linesCompleted([LineCompletionInfo])

    /// The slimes finished their removal animation and are no longer in the scene
    case slimesFinishedDespawning(LineCompletionInfo)
    
    case newSlimesPrepared([Slime])
}

extension GameEvent {
    var localizedDescription: String {
        switch self {
        case .playableAreaSetupComplete(_, _):
            return "playableAreaSetupComplete"
        case .boardVisualizationComplete(_):
            return "boardVisualizationComplete"
        case .swipe(let direction, let index):
            return "swipe \(direction) at: \(index)"
        case .slimesFinishedMovement:
            return "slimesFinishedMovement"
        case .linesCompleted(let completions):
            guard let first = completions.first else {
                return "linesCompleted event sent with no lines completed"
            }
            return "linesCompleted \(completions.count) lines"
        case .slimesFinishedDespawning(let completion):
            return "slimesFinishedDespawning at \(completion.lineType)  \(completion.index)"
        case .newSlimesPrepared(let slimes):
            return "newSlimesPrepared: \(slimes.count) slimes"
        }
    }
}
