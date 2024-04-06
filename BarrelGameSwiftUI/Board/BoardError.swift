//
//  BoardError.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation

enum BoardError: Error {
    case failedToGenerateGameBoard
    case failedToGetTile(Int, Int)
    case failedToMove(Direction, Int?, Int?)
}

extension BoardError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToGenerateGameBoard:
            return "failedToGenerateGameBoard with appropriate amount of tiles"
        case .failedToGetTile(let row, let column):
            return "failedToGetTile at row: \(row) and column \(column)"
        case .failedToMove(let direction, let row, let column):
            return "failedToMove \(direction), \(String(describing: row)), \(String(describing: column))"
        }
    }
}
