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
    case slimesMoved
    
    /// A line has been succesfully completed durring the game loop
    case lineCompleted(LineCompletionInfo)
}
