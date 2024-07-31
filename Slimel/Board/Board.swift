//
//  Board.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import Foundation
import Combine

/// A 2D Array reprentation of the playable area.  Generates the initial board state, detects and informs
/// of row/column completion, generates new rows and columns once completed.  Uses a matrix of `Tile`s
/// to track which types of slimes are where.
class Board {
    private let logger = Logger(source: Board.self)
    
    public var gameEvents = PassthroughSubject<GameEvent, Never>()

    private var matrix = [[Tile]]()

    private var rowCount: Int
    private var columnCount: Int
    private var totalTiles: Int {
        return rowCount * columnCount
    }
    
    // MARK: Initialization
    
    init(rows: Int, columns: Int) {
        self.rowCount = rows
        self.columnCount = columns
    }

    // MARK: Public
    
    
    /// Fetch the state of a tile at a given position
    /// - Parameters:
    ///   - row: The row of the tile
    ///   - column: The column of the tile
    /// - Returns: The state of the tile
    public func getTileState(row: Int, column: Int) -> Tile.State {
        guard row < rowCount,
              column < columnCount else {
            logger.error(BoardError.failedToGetTile(row, column))
            return Tile.State.empty
        }
        return matrix[row][column].state
    }

    /// Generates and assigns a randomized board to `matrix` that is ready to be played
    /// A game ready board constitutes the following:
    /// - Two thirds of  the `totalTiles` are filled
    /// - Half of the filled tiles are red
    /// - Half of the filled tiles are blue
    /// - The arrangement of the filled tiles is random
    /// - No Line Completions are in the matrix
    public func generateGameReadyBoard() {
        logger.info("generateGameReadyBoard")

        // Reset the matrix
        matrix = createMatrix(rows: rowCount, columns: columnCount, startingState: .empty)
        
        // Get a list of randomized states
        let tileStates = getRandomizedTileStates()
        
        // Filter the randomized array into the matrix
        for row in 0...rowCount - 1 {
            for column in 0...columnCount - 1 {
                let index = row * columnCount + column // Calculate the flat index
                let state = tileStates[index] // Directly access the state
                matrix[row][column] = Tile(state: state, position: (row: row, column: column))
            }
        }
        
        // If there are any completions (this should be very rare) regenerate.
        guard getLineCompletions().isEmpty else {
            generateGameReadyBoard()
            return
        }
    }

    public func move(direction: Direction, index: Int) {
        logger.info("move: \(direction), \(index))")
        switch direction {
        case .up:
            moveUp(column: index)
        case .down:
            moveDown(column: index)
        case .left:
            moveLeft(row: index)
        case .right:
            moveRight(row: index)
        }
    }
    
    public func checkAndHandleLineCompletion() {
        logger.info("checkAndHandleLineCompletion")
        let completions = getLineCompletions()
        guard completions.isEmpty == false else { return }
        for completion in completions {
            updateCompletedLineToEmpty(for: completion)
        }
        gameEvents.send(.linesCompleted(completions))
    }
    
    @discardableResult
    public func generateNewLine(for completion: LineCompletionInfo) -> LineRegenerationInfo {
        logger.info("regenerateLine at \(completion.lineType) \(completion.index)")
        
        // Get the states
        let newStates = getRandomizedTileStatesForNewLine(
            biasAgainst: completion.state,
            count: completion.lineType == .row ? rowCount : columnCount)
        
        // Update the Matirx
        let tiles = populateMatrixLine(completion.lineType, at: completion.index, with: newStates)
        
        // Create and return the necessary info to update visuals
        let regenInfo = LineRegenerationInfo(
            lineType: completion.lineType,
            index: completion.index,
            tiles: tiles)
        
        return regenInfo
    }

    // MARK: - Generation

    /// Creates and returns a randomized array of tile states based on `rowCount` and `columnCount`
    /// - Returns: A shuffled array of `Tile.State`
    private func getRandomizedTileStates() -> [Tile.State] {
        logger.info("getRandomizedTileStates")
        
        // Get the counts for each array.  This negates truncation issues.
        let filledCount = totalTiles * 2 / 3
        let redCount = filledCount / 2
        let blueCount = filledCount - redCount
        let emptyCount = totalTiles - filledCount

        // Create starting arrays of each state
        let redArray = Array(repeating: Tile.State.red, count: redCount)
        let blueArray = Array(repeating: Tile.State.blue, count: blueCount)
        let emptyArray = Array(repeating: Tile.State.empty, count: emptyCount)
        
        // Create a combined randomized array of types
        let combinedArray = redArray + blueArray + emptyArray
        return combinedArray.shuffled()
    }
    
    /// Generates a randomized array of Tile.State, with a bias against a specified state.
    /// The function is designed to be flexible, allowing for easy addition of new states.
    /// - Parameters:
    ///   - biasAgainst: The state to bias against in the generated array.
    ///   - rowCount: The number of Tile.State items to generate.
    /// - Returns: An array of Tile.State, biased according to the provided parameters.
    private func getRandomizedTileStatesForNewLine(biasAgainst state: Tile.State, count: Int) -> [Tile.State] {
        logger.info("getRandomizedTileStates biasAgainst: \(state)")

        // Iterate through occupied state possinilities and assign a randomization weight.
        var weightedStates = [Tile.State: Int]()
        Tile.State.occupiedStates.forEach { occupiedStates in
            // The weight to be biased againt gets a lower weight.
            weightedStates[occupiedStates] = (occupiedStates == state) ? 2 : 3
        }

        // Populate the array with randomly selected states based on the weights.
        var randomizedStates: [Tile.State] = []
        for _ in 0..<count {
            randomizedStates.append(getRandomState(for: weightedStates))
        }
   
        // If all the element in the new line are equal try again.
        // There is roughly a three percent chance of this occuring.
        guard randomizedStates.allElementsEqual() == false else {
            return getRandomizedTileStatesForNewLine(biasAgainst: state, count: count)
        }

        return randomizedStates
    }
    
    // MARK: - Movement

    private func moveRight(row: Int) {
        logger.info("moveRight(row): \(row)")
        guard row < rowCount else { return }
        
        // Get the row's states
        var statesInRow = matrix[row].map { $0.state }
        
        // Get the non empty states
        let nonEmptyStates = statesInRow.filter { $0 != .empty }
        
        // Cunt the empty states so we no how many to add to the left
        let emptyStatesCount = statesInRow.count - nonEmptyStates.count

        // Rearrange the row in the correct sequence of states
        statesInRow = Array(repeating: .empty, count: emptyStatesCount) + nonEmptyStates

        // Update the states of the tiles in the matrix based on our state sequence
        for (column, state) in statesInRow.enumerated() {
            matrix[row][column].updateState(state)
        }
    }

    private func moveLeft(row: Int) {
        logger.info("moveLeft(row): \(row)")
        guard row < rowCount else { return }

        var statesInRow = matrix[row].map { $0.state}
        let nonEmptyStates = statesInRow.filter({ $0 != .empty })
        let emptyStateCount = statesInRow.count - nonEmptyStates.count
        
        // Create an array of the appropriately ordered states
        statesInRow = nonEmptyStates + Array(repeating: .empty, count: emptyStateCount)
        
        for (column, state) in statesInRow.enumerated() {
            matrix[row][column].updateState(state)
        }
    }

    private func moveUp(column: Int) {
        logger.info("moveUp(column): \(column)")
        guard column < columnCount else { return }

        var statesInColumn = matrix.map { $0[column].state }
        let nonEmptyStates = statesInColumn.filter { $0 != .empty }
        let emptyStatesCount = statesInColumn.count - nonEmptyStates.count

        // Create the new state sequence for the column
        statesInColumn = nonEmptyStates + Array(repeating: .empty, count: emptyStatesCount)

        // Update the states of the tiles in the matrix
        for (row, state) in statesInColumn.enumerated() {
            matrix[row][column].updateState(state)
        }
    }
    
    private func moveDown(column: Int) {
        logger.info("moveDown(column): \(column)")
        guard column < columnCount else { return }

        var statesInColumn = matrix.map { $0[column].state }
        let nonEmptyStates = statesInColumn.filter { $0 != .empty }
        let emptyStatesCount = statesInColumn.count - nonEmptyStates.count

        // Create the new state sequence for the column
        statesInColumn = Array(repeating: .empty, count: emptyStatesCount) + nonEmptyStates

        // Update the states of the tiles in the matrix
        for (row, state) in statesInColumn.enumerated() {
            matrix[row][column].updateState(state)
        }
    }
    
    // MARK: Completion & Regen
    
    private func getLineCompletions() -> [LineCompletionInfo] {
        logger.info("getLineCompletions")
        let rowCompletions = getRowCompletions()
        let columnCompletions = getColumnCompletions()
        return rowCompletions + columnCompletions
    }

    private func getRowCompletions() -> [LineCompletionInfo] {
        var completedRows = [LineCompletionInfo]()

        for row in 0..<rowCount {
            // Skip row if the first tile is empty
            let firstState = getTileState(row: row, column: 0)
            guard firstState.isOccupied else { continue }

            // We start true until proven otherwise
            var isComplete = true

            // Start from the second tile
            for column in 1..<columnCount {
                let currentState = getTileState(row: row, column: column)
                if currentState != firstState || currentState.isOccupied == false {
                    // Exit the loop early as this row is not complete
                    isComplete = false
                    break
                }
            }

            if isComplete {
                let info = LineCompletionInfo(lineType: .row, index: row, state: firstState)
                completedRows.append(info)
            }
        }

        return completedRows
    }

    private func getColumnCompletions() -> [LineCompletionInfo] {
        var completedColumns = [LineCompletionInfo]()

        for column in 0..<columnCount {
            // Skip column if the first tile is empty
            let firstState = getTileState(row: 0, column: column)
            guard firstState.isOccupied else { continue }

            var isComplete = true

            // Start from the second tile/
            for row in 1..<rowCount {
                let currentState = getTileState(row: row, column: column)
                if currentState != firstState || !currentState.isOccupied {
                    // Exit the loop early as this column is not complete
                    isComplete = false
                    break
                }
            }

            if isComplete {
                let info = LineCompletionInfo(lineType: .column, index: column, state: firstState)
                completedColumns.append(info)
            }
        }

        return completedColumns
    }

    private func updateCompletedLineToEmpty(for completion: LineCompletionInfo) {
        switch completion.lineType {
        case .row:
            for column in 0..<columnCount {
                matrix[completion.index][column].updateState(.empty)
            }
        case .column:
            for row in 0..<rowCount {
                matrix[row][completion.index].updateState(.empty)
            }
        }
    }
    
    @discardableResult
    private func populateMatrixLine(_ lineType: LineType, at index: Int, with states: [Tile.State]) -> [Tile] {
        var tiles = [Tile]()
        switch lineType {
        case .row:
            for column in 0..<columnCount {
                let tile = Tile(
                    state: states[column],
                    position: (row: index, column: column))
                matrix[index][column] = tile
                tiles.append(tile)
            }
        case .column:
            for row in 0..<rowCount {
                let tile = Tile(
                    state: states[row],
                    position: (row: row, column: index))
                matrix[row][index] = tile
                tiles.append(tile)
            }
        }
        
        return tiles
    }

    // MARK: Helpers
    
    private func createMatrix(rows: Int, columns: Int, startingState: Tile.State) -> [[Tile]] {
        logger.info("createMatrix(rows: \(rows), columns: \(columns), startingState: \(startingState.rawValue)")
        let matrix = Array(
            repeating: Array(
                repeating: Tile(state: startingState, position: (row: 0, column: 0)),
                count: columns),
            count: rows)
        return matrix
    }
    
    /// Selects a random Tile.State based on provided weights. This function ensures that
    /// the selection process respects the bias weights assigned to each state.
    ///
    /// - Parameter weights: A dictionary where each key is a Tile.State and its value is the
    ///   weight (the likelihood) of selecting that state.
    /// - Returns: A randomly selected Tile.State, considering the specified weights.
    private func getRandomState(for weightedDictionary: [Tile.State: Int]) -> Tile.State {
        // Calculate the sum of all weights.
        let totalWeight = weightedDictionary.values.reduce(0, +)
        // Generate a random point within the total weight range.
        var randomWeightPoint = Int.random(in: 1...totalWeight)

        // Determine which state corresponds to the randomWeightPoint.
        for (state, weight) in weightedDictionary {
            randomWeightPoint -= weight
            if randomWeightPoint <= 0 {
                return state // Return the state once the randomWeightPoint falls to or below zero.
            }
        }

        // This should never be reached. Check the weights and totalWeight calculation.
        // Worst case scenario just return any state for some elegent error handling.
        logger.error(BoardError.failedToGetWeightedState)
        return Tile.State.red
    }
}

extension Board {
    public func prettyPrintMatrix() {
        var maxStateLength = 0
        var maxPositionLength = 0

        // Determine the maximum length needed for state and position representations
        for row in matrix {
            for item in row {
                let stateLength = "\(item.state)".count
                if stateLength > maxStateLength {
                    maxStateLength = stateLength
                }
                
                let positionLength = "(\(item.position.row),\(item.position.column))".count
                if positionLength > maxPositionLength {
                    maxPositionLength = positionLength
                }
            }
        }

        let maxLength = max(maxStateLength, maxPositionLength)
        
        // Iterate over each row in the matrix to print it
        for row in matrix {
            var rowStateString = "|"
            var rowPositionString = "|"

            for item in row {
                let stateString = "\(item.state)".padding(toLength: maxLength, withPad: " ", startingAt: 0)
                rowStateString += " \(stateString) |"

                let positionString = "(\(item.position.row),\(item.position.column))".padding(toLength: maxLength, withPad: " ", startingAt: 0)
                rowPositionString += " \(positionString) |"
            }

            // Print the state row followed by the position row for each tile
            print(rowStateString)
            print(rowPositionString)
        }
    }
}
