//
//  BoardError.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation

enum BoardError: Error {
    case failedToGenerateGameBoard
}

extension BoardError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToGenerateGameBoard:
            return "failedToGenerateGameBoard with appropriate amount of tiles"
        }
    }
}
