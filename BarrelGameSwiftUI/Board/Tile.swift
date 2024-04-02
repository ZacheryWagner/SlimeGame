//
//  Tile.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/29/24.
//

import Foundation

/// Data model representing a `Tile` in the `Board`
struct Tile {
    enum State: String {
        case empty
        case red
        case blue
    }

    /// State represented by how the Tile is being occupied
    public private(set) var state: State = .empty

    /// The position of the Tile in relation to its matrix.  This should never change.
    public let position: (row: Int, column: Int)
    
    init(state: State, position: (row: Int, column: Int)) {
        self.state = state
        self.position = position
    }
    
    public mutating func updateState(_ state: State) {
        self.state = state
    }
}
