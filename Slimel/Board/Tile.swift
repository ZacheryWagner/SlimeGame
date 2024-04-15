//
//  Tile.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/29/24.
//

import Foundation

/// Data model representing a spot in the `Board` matrix.
/// Maintains a consistent position based on placement in the Board but
/// updates state and Slimes move over it.
struct Tile {
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

// MARK: State

extension Tile {
    enum State: String, Equatable {
        case empty
        case red
        case blue
        
        public var asGenus: Slime.Genus? {
            switch self {
            case .empty:
                return nil
            case .red:
                return .red
            case .blue:
                return .blue
            }
        }
        
        public var isOccupied: Bool {
            return self != .empty
        }
        
        static var occupiedStates: [State] {
            return [.red, .blue]
        }
        
        static func == (lhs: Tile.State, rhs: Tile.State) -> Bool {
            return lhs.rawValue == rhs.rawValue
        }
    }
}
