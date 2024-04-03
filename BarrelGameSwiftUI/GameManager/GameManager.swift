//
//  GameManager.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation
import SpriteKit
import Combine

class GameManager: SlimeGameSceneDelegate, BoardVisualizerDelegate {
    private var state: GameState = .unititialized
    private let board: Board
    private let scene: SlimeGameScene
    private var boardVisualizer: BoardVisualizing
    
    init(board: Board, scene: SlimeGameScene, boardVisualizer: BoardVisualizing) {
        self.board = board
        self.scene = scene
        self.boardVisualizer = boardVisualizer
        setupListeners()
        initializeGame()
    }
    
    private func setupListeners() {
        scene.setupDelegate = self
        boardVisualizer.updateDelegate = self
    }
    
    private func initializeGame() {
        Logger.info("initializeGame")
        board.generateGameReadyBoard()
        scene.setupWorld()
    }
    
    // MARK: SlimeGameSceneDelegate
    
    func didSetupPlayableArea(with frame: CGRect) {
        boardVisualizer.update(for: board, in: frame)
    }
    
    // MARK: BoardVisualizerDelegate
    
    func didUpdateSlimes(_ slimes: [[Slime?]]) {
        state = .ready
        scene.inject(slimes: slimes)
    }
    
    func start() {
        guard state == .ready else { return }
    }
}
