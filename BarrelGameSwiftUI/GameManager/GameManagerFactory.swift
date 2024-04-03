//
//  GameManagerFactory.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation

class GameManagerFactory {
    static func make() -> GameManager {
        var board = Board(rows: Constants.rows, columns: Constants.columns)
        var scene = SlimeGameScene()
        var boardVisualizer = BoardVisualizer()
        return GameManager(board: board, scene: scene, boardVisualizer: boardVisualizer)
    }
}
