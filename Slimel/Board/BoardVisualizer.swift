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
    private var slimeMatrix = [[Slime?]]()

    /// Used to determine grid size
    private let sampleSlime = Slime(genus: .red)
    
    /// Used to send completion event once all animations in a movement are finished
    private var animationsCount: Int = 0
    private var animationsCompleted: Int = 0
    private var animationCompletionEventSent: Bool = false
    
    /// Cached Positions
    private var positionDictionary: [String: CGPoint] = [:]
    private var startX: CGFloat = 0
    private var startY: CGFloat = 0
    private var center: CGPoint?
    
    private var isPlayingGame: Bool = false
    private var animationTimer: Timer?
    private var currentDirection: Direction = .down
        
    init() {}
    
    // MARK: BoardVisualizing
    
    public func setup(for center: CGPoint) {
        self.center = center
        removeAllSlimesFromParent()
        calculateStartPosition()
        generatePositionDictionary()
    }
    
    public func startMenuSequence() {
        slimeMatrix = Array(repeating: Array(repeating: nil, count: Constants.columns), count: Constants.rows)
        let gabbi = Slime(genus: .red)
        let noah = Slime(genus: .red)
        let lastColumn = Constants.columns-1
        slimeMatrix[0][lastColumn] = gabbi
        slimeMatrix[1][lastColumn] = noah
        
        gabbi.position = getPositionFor(row: 0, column: lastColumn)!
        noah.position = getPositionFor(row: 1, column: lastColumn)!
        
        events.send(.newSlimesPrepared([gabbi, noah]))

        startAnimatingMenuSlimes(column: lastColumn)
    }
    
    // Starts the animation loop
    func startAnimatingMenuSlimes(column: Int) {
        // Invalidate existing timer if running
        animationTimer?.invalidate()

        // Initialize the currentDirection if you want to start with a specific pattern
        currentDirection = .down

        // Schedule a new repeating timer
        animationTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.animateSlimeMovementInColumn(column, direction: self.currentDirection)
            currentDirection.flip()
        }
    }

    /// Create and populate the starting matrix of slimes
    /// Set their positions appropriately to be scene ready
    /// Inform the GameManager when done
    /// - Parameters:
    ///   - board: The data model for generating slimes
    public func createSlimes(for board: Board) {
        isPlayingGame = true
        removeAllSlimesFromParent()
        animationTimer?.invalidate()

        slimeMatrix = Array(repeating: Array(repeating: nil, count: Constants.columns), count: Constants.rows)
        setSlimes(for: board)
        events.send(GameEvent.boardVisualizationComplete(slimeMatrix))
    }

    
    /// Move all slimes in a given row or column
    /// - Parameters:
    ///   - direction: The direction to move the slimes
    ///   - index: The index of the row or column to move the slimes
    public func animateSlimesForSwipe(direction: Direction, index: Int) {
        logger.info("animateSlimesForSwipe direction: \(direction), index: \(index)")
        switch direction {
        case .left, .right:
            animateSlimeMovementInRow(index, direction: direction)
        case .up, .down:
            animateSlimeMovementInColumn(index, direction: direction)
        }
    }
    
    
    /// Handle slime removal both from the matrix and animations
    /// Send a `slimesFinishedDespawning` when done.
    ///
    /// - Parameter completions: data model with completion details
    public func handleLineCompletions(_ completions: [LineCompletionInfo]) {
        for completion in completions {
            handleLineCompletion(completion)
        }
    }
    
    func generateNewSlimes(from lineRegenInfo: LineRegenerationInfo) {
        // Create the new array of slimes based on tile states
        var newSlimes = [Slime]()
        for tile in lineRegenInfo.tiles {
            if let slime = createSlime(from: tile) {
                newSlimes.append(slime)
            }
        }

        // Update the visualizer’s matrix and prepare slimes for injection.
        updateSlimeMatrix(
            with: newSlimes,
            for: lineRegenInfo.lineType,
            at: lineRegenInfo.index)
        events.send(.newSlimesPrepared(newSlimes))
    }
    
    // MARK: Initial Generation
    
    /// Calulates the first slimes start position based on `Center`
    private func calculateStartPosition() {
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
                    
                    slimeMatrix[row][column] = slime
                }
            }
        }
    }
    
    // MARK: Movement

    private func animateSlimeMovementInRow(_ row: Int, direction: Direction) {
        guard row < Constants.rows else { return }

        // Temporary array to hold the new state of the row
        var newRow = [Slime?](repeating: nil, count: Constants.columns)
        let nonEmptySlimes = slimeMatrix[row].compactMap { $0 }
        
        prepareForAnimation(with: nonEmptySlimes.count)

        // Determine where the first slime should move based on the direction
        let startIndex = direction == .right ? Constants.columns - nonEmptySlimes.count : 0

        // For all slimes
        for (index, slime) in nonEmptySlimes.enumerated() {
            let targetColumn = startIndex + index
            newRow[targetColumn] = slime // Update the new row state

            // Use the position dictionary to animate the slime to its new position
            if let newPosition = getPositionFor(row: row, column: targetColumn) {
                slime.updateTexture(in: direction)
                animateSlimeMovement(slime, to: newPosition) { [weak self] in
                    guard let self = self else { return }
                    slime.updateTextureToIdle()
                    if self.isPlayingGame {
                        self.animationDidComplete()
                    }
                }
            }
        }

        // Update the matrix to reflect the new row state
        slimeMatrix[row] = newRow
    }

    private func animateSlimeMovementInColumn(_ column: Int, direction: Direction) {
        guard column < Constants.columns else { return }

        // Temporary array to hold the new state of the column
        var newColumn = [Slime?](repeating: nil, count: Constants.rows)
        let nonEmptySlimes = slimeMatrix.map { $0[column] }.compactMap { $0 }
        
        prepareForAnimation(with: nonEmptySlimes.count)

        // Determine where the first slime should move based on the direction
        let startIndex = direction == .down ? Constants.rows - nonEmptySlimes.count : 0

        // For all slimes
        for (index, slime) in nonEmptySlimes.enumerated() {
            let targetRow = startIndex + index
            newColumn[targetRow] = slime // Update the new column state

            // Animate the slime to its new position using the position dictionary
            if let newPosition = getPositionFor(row: targetRow, column: column) {
                slime.updateTexture(in: direction)
                animateSlimeMovement(slime, to: newPosition) { [weak self] in
                    guard let self = self else { return }
                    slime.updateTextureToIdle()
                    if self.isPlayingGame {
                        self.animationDidComplete()
                    } 
                }
            }
        }

        // Update each row in the matrix to reflect the new column state
        for rowIndex in 0..<Constants.rows {
            slimeMatrix[rowIndex][column] = newColumn[rowIndex]
        }
    }

    private func animateSlimeMovement(_ slime: Slime, to position: CGPoint, withCompletion completion: @escaping () -> Void) {
        let slideDuration = isPlayingGame ? Constants.slimeMoveDuration : 3
        let moveAction = SKAction.move(to: position, duration: slideDuration)
        let scaleUpAction = SKAction.scale(to: Constants.slimeMoveBounceScale, duration: slideDuration * 0.5)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: slideDuration * 0.5)
        let bounceAction = SKAction.sequence([scaleUpAction, scaleDownAction])
        let groupAction = SKAction.group([moveAction, bounceAction])
        groupAction.timingMode = .easeOut
        
        slime.run(groupAction, completion: completion)
    }

    private func prepareForAnimation(with count: Int) {
        animationsCount = count
        animationsCompleted = 0
        animationCompletionEventSent = false
    }

    private func animationDidComplete() {
        animationsCompleted += 1
        if animationsCompleted == animationsCount && !animationCompletionEventSent {
            animationCompletionEventSent = true
            events.send(.slimesFinishedMovement)
        }
    }
    
    // MARK: Completion & Removal
    
    private func handleLineCompletion(_ completion: LineCompletionInfo) {
        switch completion.lineType {
        case .row:
            animateAndRemoveSlimesInRow(at: completion.index, completion: { [weak self] in
                self?.events.send(.slimesFinishedDespawning(completion))
            })
        case .column:
            animateAndRemoveSlimesInColumn(at: completion.index, completion: { [weak self] in
                self?.events.send(.slimesFinishedDespawning(completion))
            })
        }
    }
    
    private func animateAndRemoveSlimesInRow(at rowIndex: Int, completion: @escaping () -> Void) {
        guard rowIndex < slimeMatrix.count else { return }

        let animationGroup = DispatchGroup()

        for (columnIndex, slime) in slimeMatrix[rowIndex].enumerated() {
            guard let slime = slime else { continue }
            animationGroup.enter()

            animateRemoval(of: slime) {
                self.slimeMatrix[rowIndex][columnIndex] = nil
                animationGroup.leave()
            }
        }

        animationGroup.notify(queue: .main, execute: completion)
    }

    private func animateAndRemoveSlimesInColumn(at columnIndex: Int, completion: @escaping () -> Void) {
        guard columnIndex < slimeMatrix.first?.count ?? 0 else { return }
        
        let animationGroup = DispatchGroup()
        
        for rowIndex in 0..<slimeMatrix.count {
            guard let slime = slimeMatrix[rowIndex][columnIndex] else { continue }
            animationGroup.enter()
            
            animateRemoval(of: slime) {
                self.slimeMatrix[rowIndex][columnIndex] = nil
                animationGroup.leave()
            }
        }

        animationGroup.notify(queue: .main, execute: completion)
    }

    
    private func animateRemoval(of slime: Slime, completion: @escaping () -> Void) {
        // Configure the bounce and shrink actions
        let scaleUpAction = SKAction.scale(to: 1.1, duration: Constants.slimeDespawnDuration/3)
        let scaleDownAction = SKAction.scale(to: 0, duration: (Constants.slimeDespawnDuration/3) * 2)
        scaleDownAction.timingMode = .easeIn
        
        // Create a sequence for the bounce effect followed by shrink
        let sequence = SKAction.sequence([scaleUpAction, scaleDownAction])
        
        slime.run(sequence) {
            slime.removeFromParent()
            completion()
        }
    }
    
    private func removeAllSlimesFromParent() {
        for column in slimeMatrix {
            for slime in column {
                guard let slime = slime else { return }
                animateRemoval(of: slime) {}
            }
        }
    }
    
    // MARK: Regeneration
    
    private func createSlime(from tile: Tile) -> Slime? {
        guard tile.state.isOccupied else { return nil }

        guard let state = tile.state.asGenus else {
            logger.error(BoardVisualizerError.failedToCreateSlimeForTileState(tile.state))
            return nil
        }

        guard let position = getPositionFor(
            row: tile.position.row,
            column: tile.position.column) else {
            logger.error(BoardVisualizerError.failedToCreateSlimePositionNil)
            return nil
        }

        let slime = Slime(genus: state)
        slime.position = position
        return slime
    }

    /// Updates the `slimeMatrix` with a new set of slimes for a specified row or column.
    /// - Parameters:
    ///   - newSlimes: The new slimes to insert into the matrix.
    ///   - lineType: Indicates whether the update is for a row or a column.
    ///   - index: The index of the row or column to update.
    func updateSlimeMatrix(with newSlimes: [Slime?], for lineType: LineType, at index: Int) {
        switch lineType {
        case .row:
            guard index < slimeMatrix.count else {
                logger.error("Row index out of bounds.")
                return
            }

            // Ensure we're replacing the correct row with new slimes.
            slimeMatrix[index] = newSlimes
            
        case .column:
            guard !slimeMatrix.isEmpty, index < slimeMatrix[0].count else {
                logger.error("Column index out of bounds.")
                return
            }
            // Iterate through each row in the column, updating the slime at the given column index.
            for rowIndex in 0..<slimeMatrix.count {
                if rowIndex < newSlimes.count {
                    slimeMatrix[rowIndex][index] = newSlimes[rowIndex]
                } else {
                    logger.error("New slimes array for column update is out of sync with the matrix size.")
                    break
                }
            }
        }
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
