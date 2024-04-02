//
//  GameManager.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation
import SpriteKit

private let rows: Int = 6
private let columns: Int = 6

class GameManager {
    private var scene = SlimeGameScene()
    private var board = Board(rows: rows, columns: columns, startingState: .empty)
    private var slimes: [[Slime?]] = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    
    init() {
        initializeGame()
    }
    
    private func initializeGame() {
        Logger.info("initializeGame")
        board.generateGameReadyBoard()
        setupSlimes()
    }
    
    private func setupSlimes() {
        Logger.info("setupSlimes")
        for row in 0..<rows {
            for column in 0..<columns {
                
            }
        }
    }
}
