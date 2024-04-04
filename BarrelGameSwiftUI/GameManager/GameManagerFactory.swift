//
//  GameManagerFactory.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation

class GameManagerFactory {
    static func make() -> GameManager {
        let board = Board(rows: Constants.rows, columns: Constants.columns)
        let scene = SlimeGameScene()
        let boardVisualizer = BoardVisualizer()
        return GameManager(board: board, scene: scene, boardVisualizer: boardVisualizer)
    }
}
