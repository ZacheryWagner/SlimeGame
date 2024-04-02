//
//  Board.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import Foundation

class Board {
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
    public func getTileState(row: Int, column: Int) -> Tile.State? {
        guard row < rowCount,
              column < columnCount else {
            Logger.error(BoardError.failedToGetTile(row, column))
            return nil
        }
        return matrix[row][column].state
    }

    /// Generates and assigns a randomized board to `matrix` that is ready to be played
    /// A game ready board constitutes the following:
    /// - Two thirds of  the `totalTiles` are filled
    /// - Half of the filled tiles are red
    /// - Half of the filled tiles are blue
    /// - The arrangement of the filled tiles is random
    public func generateGameReadyBoard() {
        Logger.info("generateGameReadyBoard")

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
    }


    /// Creates and returns a randomized array of tile states based on `rowCount` and `columnCount`
    /// - Returns: A shuffled array of `Tile.State`
    private func getRandomizedTileStates() -> [Tile.State] {
        Logger.info("getRandomizedTileStates")
        
        // Get the counts for each array.  This negates truncation issues.
        let filledCount = totalTiles * 2 / 3
        let redCount = filledCount / 2
        let blueCount = filledCount - redCount
        let emptyCount = totalTiles - filledCount

        // Create starting arrays of each state
        let startingAmount: Int = totalTiles / 3
        let redArray = Array(repeating: Tile.State.red, count: redCount)
        let blueArray = Array(repeating: Tile.State.blue, count: blueCount)
        let emptyArray = Array(repeating: Tile.State.empty, count: emptyCount)
        
        // Create a combined randomized array of types
        let combinedArray = redArray + blueArray + emptyArray
        return combinedArray.shuffled()
    }

    public func moveRight(row: Int) {
        Logger.info("moveRight(row): \(row)")
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
    
    public func moveLeft(row: Int) {
        Logger.info("moveLeft(row): \(row)")
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
    
    public func moveUp(column: Int) {
        Logger.info("moveUp(column): \(column)")
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
    
    public func moveDown(column: Int) {
        Logger.info("moveDown(column): \(column)")
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

    // MARK: Private
    
    private func createMatrix(rows: Int, columns: Int, startingState: Tile.State) -> [[Tile]] {
        Logger.info("createMatrix(rows: \(rows), columns: \(columns), startingState: \(startingState.rawValue)")
        let matrix = Array(
            repeating: Array(repeating: Tile(state: startingState, position: (row: 0, column: 0)), count: columns),
            count: rows)
        return matrix
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
