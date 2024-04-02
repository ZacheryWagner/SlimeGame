//
//  Board.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import Foundation

struct Board {
    private var matrix = [[Tile]]()
    
    private var rowCount: Int
    private var columnCount: Int
    private var totalTiles: Int {
        return rowCount * columnCount
    }
    
    // MARK: Initialization
    
    init(rows: Int, columns: Int, startingState: Tile.State) {
        self.rowCount = rows
        self.columnCount = columns
        self.matrix = createMatrix(rows: rows, columns: columns, startingState: startingState)
    }

    // MARK: Public
    
    public func getTile(row: Int, column: Int) -> Tile? {
        guard row < rowCount - 1,
              column < columnCount - 1 else {
            Logger.error(BoardError.failedToGetTile(row, column))
            return nil
        }
        return matrix[row][column]
    }

    /// Generates and assigns a randomized board to `matrix` that is ready to be played
    /// A game ready board constitutes the following:
    /// - Two thirds of  the `totalTiles` are filled
    /// - Half of the filled tiles are red
    /// - Half of the filled tiles are blue
    /// - The arrangement of the filled tiles is random
    public mutating func generateGameReadyBoard() {
        Logger.info("generateGameReadyBoard")
        // Create our starting arrays of each type
        let startingAmount: Int = totalTiles / 3
        let redArray = Array(repeating: Tile(state: .red), count: startingAmount)
        let blueArray = Array(repeating: Tile(state: .blue), count: startingAmount)
        let emptyArray = Array(repeating: Tile(state: .empty), count: startingAmount)
        
        // Create a combined randomized array
        var combinedArray = redArray + blueArray + emptyArray
        combinedArray.shuffle()
        
        // Filter the randomized array into the matrix
        for row in 0...rowCount - 1 {
            for column in 0...columnCount - 1 {
                guard let tile = combinedArray.first else {
                    print("[ERROR] \(BoardError.failedToGenerateGameBoard.localizedDescription)")
                    return
                }
                matrix[row][column] = tile
                combinedArray.removeFirst()
            }
        }
    }

    public mutating func moveRight(row: Int) {
        Logger.info("moveRight(row): \(row)")
        let nonEmptyTiles: [Tile] = matrix[row].filter { $0.state != .empty }
        let emptyTilesCount = matrix[row].count - nonEmptyTiles.count
        
        // Fill the beginning of the row with empty tiles
        matrix[row] = Array(repeating: Tile(state: .empty), count: emptyTilesCount)
        
        // Append the non-empty tiles to the end of the row
        matrix[row] += nonEmptyTiles
    }
    
    public mutating func moveLeft(row: Int) {
        Logger.info("moveLeft(row): \(row)")
        let nonEmptyTiles: [Tile] = matrix[row].filter { $0.state != .empty }
        let emptyTilesCount = matrix[row].count - nonEmptyTiles.count
        
        // Append the non-empty tiles to the end of the row
        matrix[row] = nonEmptyTiles

        // Fill the beginning of the row with empty tiles
        matrix[row] += Array(repeating: Tile(state: .empty), count: emptyTilesCount)
    }
    
    public mutating func moveUp(column: Int) {
        Logger.info("moveUp(column): \(column)")
        var nonEmptyTiles: [Tile] = []
        var emptyTilesCount = 0
        
        // Collect non-empty tiles and count empty tiles in the column
        for row in matrix.indices {
            if matrix[row][column].state != .empty {
                nonEmptyTiles.append(matrix[row][column])
            } else {
                emptyTilesCount += 1
            }
        }
        
        // Reconstruct the column with non-empty tiles at the top
        for row in 0..<nonEmptyTiles.count {
            matrix[row][column] = nonEmptyTiles[row]
        }
        for row in nonEmptyTiles.count..<matrix.count {
            matrix[row][column] = Tile(state: .empty)
        }
    }
    
    public mutating func moveDown(column: Int) {
        Logger.info("moveDown(column): \(column)")
        var nonEmptyTiles: [Tile] = []
        var emptyTilesCount = 0
        
        // Collect non-empty tiles and count empty tiles in the column
        for row in matrix.indices {
            if matrix[row][column].state != .empty {
                nonEmptyTiles.append(matrix[row][column])
            } else {
                emptyTilesCount += 1
            }
        }
        
        // Reconstruct the column with non-empty tiles at the bottom
        for row in 0..<emptyTilesCount {
            matrix[row][column] = Tile(state: .empty)
        }
        for row in emptyTilesCount..<matrix.count {
            matrix[row][column] = nonEmptyTiles[row - emptyTilesCount]
        }
    }

    // MARK: Private
    
    private func createMatrix(rows: Int, columns: Int, startingState: Tile.State) -> [[Tile]] {
        Logger.info("createMatrix(rows: \(rows), columns: \(columns), startingState: \(startingState.rawValue)")
        let matrix = Array(
            repeating: Array(repeating: Tile(state: startingState), count: columns),
            count: rows)
        return matrix
    }
}

extension Board {
    public func prettyPrintMatrix() {
        var maxLength = 0
        for row in matrix {
            for item in row {
                let itemLength = "\(item.stateDescrpition)".count
                if itemLength > maxLength {
                    maxLength = itemLength
                }
            }
        }
        
        // Iterate over each row in the matrix to print it
        for row in matrix {
            // Start the row with a vertical bar
            var rowString = "|"
            
            for item in row {
                let itemString = "\(item.stateDescrpition)"
                
                // Create a padded version of the item string so that it aligns correctly in its column.
                let paddedItem = itemString.padding(toLength: maxLength, withPad: " ", startingAt: 0)
                
                // Append the padded item string to the row string, followed by a vertical bar.
                rowString += " \(paddedItem) |"
            }
            
            // Print the complete row string
            print(rowString)
        }
    }
}
