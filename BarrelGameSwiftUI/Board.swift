//
//  Board.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import Foundation

struct Board {
    private var matrix = [[Tile]]()
    
    private var rowCount: Int = 6
    private var columnCount: Int = 6
    private var totalTiles: Int {
        return rowCount * columnCount
    }
    
    // MARK: Initialization
    
    init() {}
    
    init(rows: Int, columns: Int, startingState: Tile.State) {
        self.matrix = createMatrix(rows: rows, columns: columns, startingState: startingState)
        self.rowCount = rows
        self.columnCount = columns
    }

    // MARK: Public
    
    
    /// Generates and assigns a randomized board to `matrix` that is ready to be played
    /// A game ready board constitutes the following:
    /// - Two thirds of  the `totalTiles` are filled
    /// - Half of the filled tiles are red
    /// - Half of the filled tiles are blue
    /// - The arrangement of the filled tiles is random
    public mutating func generateGameReadyBoard() {
        print("[LOG] generateGameReadyBoard")
        
        // Initialize an empty matrix
        self.matrix = createMatrix(rows: rowCount, columns: columnCount, startingState: .empty)

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
                    print("[ERROR] generateGameReadyBoard failed to create the appropriate amount of tiles")
                    return
                }
                matrix[row][column] = tile
                combinedArray.removeFirst()
            }
        }
    }
    
    public mutating func moveRight(row: Int) {
        print("[LOG] moveRight(row): \(row)")
        let nonEmptyTiles: [Tile] = matrix[row].filter { $0.state != .empty }
        let emptyTilesCount = matrix[row].count - nonEmptyTiles.count
        
        // Fill the beginning of the row with empty tiles
        matrix[row] = Array(repeating: Tile(state: .empty), count: emptyTilesCount)
        
        // Append the non-empty tiles to the end of the row
        matrix[row] += nonEmptyTiles
    }
    
    public mutating func moveLeft(row: Int) {
        print("[LOG] moveLeft(row): \(row)")
        let nonEmptyTiles: [Tile] = matrix[row].filter { $0.state != .empty }
        let emptyTilesCount = matrix[row].count - nonEmptyTiles.count
        
        // Append the non-empty tiles to the end of the row
        matrix[row] = nonEmptyTiles

        // Fill the beginning of the row with empty tiles
        matrix[row] += Array(repeating: Tile(state: .empty), count: emptyTilesCount)
    }
    
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
    
    // MARK: Private
    
    private func createMatrix(rows: Int, columns: Int, startingState: Tile.State) -> [[Tile]] {
        let matrix = Array(
            repeating: Array(repeating: Tile(state: startingState), count: columns),
            count: rows)
        return matrix
    }
}
