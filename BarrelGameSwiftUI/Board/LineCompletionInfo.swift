//
//  LineCompletionInfo.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/7/24.
//

import Foundation

public enum LineType {
    case row
    case column
}

/// Data model representing a completed row or column.  A line is completed when
/// it has been  entirely filled with a single genus of Slime durring the game loop.
struct LineCompletionInfo {
    public let lineType: LineType
    
    public let index: Int
    
    public let state: Tile.State
    
    init(lineType: LineType, index: Int, state: Tile.State) {
        self.lineType = lineType
        self.index = index
        self.state = state
    }
}

struct LineRegenerationInfo {
    public let lineType: LineType
    
    public let index: Int
    
    public let tiles: [Tile]
    
    init(lineType: LineType, index: Int, tiles: [Tile]) {
        self.lineType = lineType
        self.index = index
        self.tiles = tiles
    }
}
