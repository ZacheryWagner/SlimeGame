//
//  Tile.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/29/24.
//

import Foundation

struct Tile {
    enum State: String {
        case empty
        case red
        case blue
    }
    
    public var state: State = .empty
    
    private var position: (row: Int, column: Int) = (0, 0)
    
    public var stateDescrpition: String {
        return state.rawValue
    }
    
    init(state: State) {
        self.state = state
    }
}
