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
    case loaded
    case startSequnce
    case playing
    case paused
    case ended
}

enum SetupEvent {
    /// The scene has finished loading textures and setting up the world
    case playableAreaSetupComplete(CGRect, CGPoint)

    /// The board has generated the slimes an assigned their positions
    case boardVisualizationComplete([[Slime?]])
    
    /// When the initial slimes are loaded
    case slimeSpawnFinished
}


enum GameEvent {
    /// There has been a completed swipe action on a given row or column
    case move(Direction, Int)

    /// The slimes have finished moving to their new place
    case movementFinished

    /// Line(s) have been succesfully completed durring the game loop
    case linesCompleted([LineCompletionInfo])

    /// The slimes finished their removal animation and are no longer in the scene
    case slimeDespawnFinished(LineCompletionInfo)
    
    case newSlimesPrepared([Slime])
    
    case slimeSpawnFinished
}

extension SetupEvent {
    var localizedDescription: String {
        switch self {
        case .playableAreaSetupComplete(_, _):
            return "playableAreaSetupComplete"
        case .boardVisualizationComplete(_):
            return "boardVisualizationComplete"
        case .slimeSpawnFinished:
            return "slimeSpawnFinished"
        }
    }
}

extension GameEvent {
    var localizedDescription: String {
        switch self {
        case .move(let direction, let index):
            return "swipe \(direction) at: \(index)"
        case .movementFinished:
            return "movementFinished"
        case .linesCompleted(let completions):
            guard completions.first != nil else {
                return "linesCompleted event sent with no lines completed"
            }
            return "linesCompleted \(completions.count) lines"
        case .slimeDespawnFinished(let completion):
            return "slimeDespawnFinished at \(completion.lineType)  \(completion.index)"
        case .newSlimesPrepared(let slimes):
            return "newSlimesPrepared: \(slimes.count) slimes"
        case .slimeSpawnFinished:
            return "slimeSpawnFinished"
        }
    }
}
