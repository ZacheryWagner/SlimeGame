//
//  BoardVisualizing.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation
import Combine

/// Generates, positions, and animates `Slime`s based on `Board` state and `SlimeGameScene` gestures.
/// Communicates with the `GameManager` via `events`
protocol BoardVisualizing {
    /// Informs the `GameManager` of  `GameEvent`s
    var events: PassthroughSubject<GameEvent, Never> { get set }
    
    
    /// Setup board positions and prepare for create
    /// - Parameter center: Used to configure positions
    func setup(for center: CGPoint)
    
    
    /// A simple animation of slimes moving to play on the menu
    func startMenuSequence()

    /// Create and populate the starting matrix of slimes
    /// Set their positions appropriately to be scene ready
    /// Inform the GameManager when done
    /// - Parameters:
    ///   - board: The data model for generating slimes
    func createSlimes(for board: Board)

    /// Move all slimes in a given row or column
    /// - Parameters:
    ///   - direction: The direction to move the slimes
    ///   - index: The index of the row or column to move the slimes
    func animateSlimesForSwipe(direction: Direction, index: Int)
    
    func handleLineCompletion(_ completion: LineCompletionInfo)
    
    func generateNewSlimes(from regenInfo: LineRegenerationInfo)
}
