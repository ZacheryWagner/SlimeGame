//
//  BoardVisualizerError.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/10/24.
//

import Foundation

enum BoardVisualizerError: Error {
    case failedToCreateSlimePositionNil
    case failedToCreateSlimeForTileState(Tile.State)
}

extension BoardVisualizerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToCreateSlimeForTileState(let tileState):
            return "failedToCreateSlimeForTileState \(tileState)"
        case .failedToCreateSlimePositionNil:
            return "failedToCreateSlimePositionNil"
        }
    }
}
