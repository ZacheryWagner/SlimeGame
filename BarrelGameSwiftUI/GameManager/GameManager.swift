//
//  GameManager.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation
import SpriteKit
import SwiftUI
import Combine

class GameManager {
    private let logger = Logger(source: GameManager.self)
    
    private var state = CurrentValueSubject<GameState, Never>(.uninitialized)
    private var cancellables = Set<AnyCancellable>()
    
    private var scene: SlimeGameScene
    private let board: Board
    private var boardVisualizer: BoardVisualizing
    
    // MARK: Initialization
    
    init(board: Board, scene: SlimeGameScene, boardVisualizer: BoardVisualizing) {
        self.board = board
        self.scene = scene
        self.boardVisualizer = boardVisualizer
        
        state.send(.loading)
    
        setupEvents()
        setupStateSubscriptions()
        initializeGame()
    }
    
    private func initializeGame() {
        logger.info("initializeGame")
        
        board.generateGameReadyBoard()
    }

    private func setupEvents() {
        scene.events
            .merge(with: boardVisualizer.events)
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
        
        scene.scaleMode = .aspectFill
    }
    
    // MARK: State Machine
    
    private func setupStateSubscriptions() {
        state
            .removeDuplicates()
            .sink { [weak self] newState in
                self?.logger.info("State Update: \(newState)")
                switch newState {
                case .uninitialized: return
                case .loading: return
                case .ready: return
                case .playing: return
                case .paused: return
                case .ended: return
                }
            }
            .store(in: &cancellables)
    }

    private func handleEvent(_ event: GameEvent) {
        switch event {
        case .playableAreaSetupComplete(_, let center):
            logger.info("handleEvent: playableAreaSetupComplete")
            board.generateGameReadyBoard()
            boardVisualizer.update(for: board, center: center)
        case .boardVisualizationComplete(let slimes):
            logger.info("handleEvent: boardVisualizationComplete")
            scene.inject(slimes: slimes)
            state.send(.ready)
        case .swipe(let direction, let index):
            logger.info("handleEvent: swipe \(direction), \(index)")
            board.move(direction: direction, index: index)
            boardVisualizer.animateSlimesForSwipe(
                direction: direction,
                index: index)
        }
    }
    
    private func transition(to newState: GameState) {
        guard state.value != newState else { return }
        state.send(newState)
    }
    
    // MARK: Game
    
    private func start() {
        guard state.value == .ready else { return }
    }
    
    // MARK: Public
    
    func getSpriteView() -> some View {
        return SpriteView(scene: scene).ignoresSafeArea()
    }
    
    func configureSceneSize(size: CGSize) {
        scene.size = size
    }
}
