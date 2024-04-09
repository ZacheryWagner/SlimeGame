//
//  BoardVisualizer.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation
import Combine
import SpriteKit


/// Generates, positions, and animates `Slime`s based on `Board` state and `SlimeGameScene` gestures.
/// Communicates with the `GameManager` via `events`
class BoardVisualizer: BoardVisualizing {
    // MARK: Properties
    
    private let logger = Logger(source: BoardVisualizer.self)

    /// Informs the `GameManager` of  `GameEvent`s
    public var events = PassthroughSubject<GameEvent, Never>()

    /// The slimes that are added to and moved around the scene
    private var slimes = [[Slime?]]()

    /// Used to determine grid size
    private let sampleSlime = Slime(genus: .red)
    
    /// Cached Positions
    private var positionDictionary: [String: CGPoint] = [:]
    private var startX: CGFloat = 0
    private var startY: CGFloat = 0
    private var center: CGPoint?
        
    init() {}
    
    // MARK: BoardVisualizing

    /// Create and populate the starting matrix of slimes
    /// Set their positions appropriately to be scene ready
    /// Inform the GameManager when done
    /// - Parameters:
    ///   - board: The data model for generating slimes
    ///   - center: The center point to base the grid on
    public func create(for board: Board, center: CGPoint) {
        self.center = center

        // Layout all possible slime positions
        setStartPosition()
        generatePositionDictionary()

        // Clear existing slimes and set new ones based on the board state
        slimes = Array(repeating: Array(repeating: nil, count: Constants.columns), count: Constants.rows)
        setSlimes(for: board)

        // Update delegate or scene with the newly positioned slimes
        events.send(GameEvent.boardVisualizationComplete(slimes))
    }

    
    /// Move all slimes in a given row or column
    /// - Parameters:
    ///   - direction: The direction to move the slimes
    ///   - index: The index of the row or column to move the slimes
    func animateSlimesForSwipe(direction: Direction, index: Int) {
        logger.info("animateSlimesForSwipe direction: \(direction), index: \(index)")
        switch direction {
        case .left, .right:
            animateSlimesInRow(index, direction: direction)
        case .up, .down:
            animateSlimesInColumn(index, direction: direction)
        }
    }
    
    // MARK: Generation
    
    /// Calulates the first slimes start position based on `Center`
    private func setStartPosition() {
        guard let center = center else { return }

        // Calculate the total grid width and height to adjust positions accordingly
        let totalGridWidth = (sampleSlime.size.width + Constants.slimePadding) * CGFloat(Constants.columns - 1)
        let totalGridHeight = (sampleSlime.size.height + Constants.slimePadding) * CGFloat(Constants.rows - 1)

        // Calculate starting positions based on the center
        startX = center.x - (totalGridWidth / 2)
        startY = center.y + (totalGridHeight / 2)
    }
    
    
    /// Populates `positionDictionary` with all possible slime positions in the grid.
    private func generatePositionDictionary() {
        positionDictionary = [:]
        for row in 0..<Constants.rows {
            for column in 0..<Constants.columns {
                let xPosition = startX + (sampleSlime.size.width + Constants.slimePadding) * CGFloat(column)
                let yPosition = startY - (sampleSlime.size.height + Constants.slimePadding) * CGFloat(row)
                let key = positionKey(row: row, column: column)
                let point = CGPoint(x: xPosition, y: yPosition)
                positionDictionary[key] = point
            }
        }
    }
    
    
    /// Creates Slimes based on the Board Tile States.
    /// Sets their positions using `positionDictionary`
    /// Adds the slimes to their relevant row/column of the `slimes` matrix
    /// - Parameter board: The data model for generating slimes
    private func setSlimes(for board: Board) {
        for row in 0..<Constants.rows {
            for column in 0..<Constants.columns {
                let tileState = board.getTileState(row: row, column: column)
                if tileState != .empty {
                    let slime = Slime(genus: tileState == .red ? .red : .blue)
                    
                    // Use the position from the positionDictionary
                    if let position = getPositionFor(row: row, column: column) {
                        slime.position = position
                    } else {
                        // Log an error or handle the missing position appropriately
                        logger.error("Position for row: \(row), column: \(column) not found in dictionary.")
                    }
                    
                    slimes[row][column] = slime
                }
            }
        }
    }
    
    // MARK: Movement

    private func animateSlimesInRow(_ row: Int, direction: Direction) {
        guard row < Constants.rows else { return }

        // Temporary array to hold the new state of the row
        var newRow = [Slime?](repeating: nil, count: Constants.columns)
        let nonEmptySlimes = slimes[row].compactMap { $0 }

        // Determine where the first slime should move based on the direction
        let startIndex = direction == .right ? Constants.columns - nonEmptySlimes.count : 0

        for (index, slime) in nonEmptySlimes.enumerated() {
            let targetColumn = startIndex + index
            newRow[targetColumn] = slime // Update the new row state

            // Use the position dictionary to animate the slime to its new position
            if let newPosition = getPositionFor(row: row, column: targetColumn) {
                slime.updateTexture(in: direction)
                animateSlime(slime, to: newPosition) {
                    slime.updateTextureToIdle()
                }
            }
        }

        // Update the matrix to reflect the new row state
        slimes[row] = newRow
    }

    private func animateSlimesInColumn(_ column: Int, direction: Direction) {
        guard column < Constants.columns else { return }

        // Temporary array to hold the new state of the column
        var newColumn = [Slime?](repeating: nil, count: Constants.rows)
        let nonEmptySlimes = slimes.map { $0[column] }.compactMap { $0 }

        // Determine where the first slime should move based on the direction
        let startIndex = direction == .down ? Constants.rows - nonEmptySlimes.count : 0

        for (index, slime) in nonEmptySlimes.enumerated() {
            let targetRow = startIndex + index
            newColumn[targetRow] = slime // Update the new column state

            // Animate the slime to its new position using the position dictionary
            if let newPosition = getPositionFor(row: targetRow, column: column) {
                slime.updateTexture(in: direction)
                animateSlime(slime, to: newPosition) {
                    slime.updateTextureToIdle()
                }
            }
        }

        // Update each row in the matrix to reflect the new column state
        for rowIndex in 0..<Constants.rows {
            slimes[rowIndex][column] = newColumn[rowIndex]
        }
    }
    
    private func animateSlime(_ slime: Slime, to position: CGPoint, withCompletion completion: @escaping () -> Void) {
        let moveAction = SKAction.move(to: position, duration: Constants.slimeSlideDuration)
        let scaleUpAction = SKAction.scale(to: 1.1, duration: Constants.slimeSlideDuration * 0.5)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: Constants.slimeSlideDuration * 0.5)
        let bounceAction = SKAction.sequence([scaleUpAction, scaleDownAction])
        let groupAction = SKAction.group([moveAction, bounceAction])
        
        slime.run(groupAction, completion: completion)
    }
    
    // MARK: Helpers
    
    private func positionKey(row: Int, column: Int) -> String {
        return "\(row)-\(column)"
    }
    
    private func getPositionFor(row: Int, column: Int) -> CGPoint? {
        let key = positionKey(row: row, column: column)
        return positionDictionary[key]
    }
}
