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


/// Manages `GameState` and fascilitates communicates between the scene and all relevent game components.
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
        
        self.scene.scaleMode = .aspectFill
        
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
            .merge(with: board.events)
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
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
    
    /**
     1. board moves -> boardVisualizer animates -> gameManager updates on complete
     
        Not an options:
        // - cant spawn durring animation
        // + simple event layout
     2.  -> board fetches line completions -> BoardVisualizer animates -> gameManager updates on complete
     3.  -> board updates -> boardVisualizer adds new slimes
     
     1. board moves -> boardVisualizer animates -> gameManager updates on complete
     2. board fetches line completions -> boardVizualizer animates
     */

    private func handleEvent(_ event: GameEvent) {
        logger.info("handleEvent: \(event.localizedDescription)")
        switch event {
        case .playableAreaSetupComplete(_, let center):
            board.generateGameReadyBoard()
            boardVisualizer.create(for: board, center: center)
        case .boardVisualizationComplete(let slimes):
            scene.inject(slimes: slimes)
            state.send(.ready)
        case .swipe(let direction, let index):
            board.move(direction: direction, index: index)
            boardVisualizer.animateSlimesForSwipe(
                direction: direction,
                index: index)
        case .slimesFinishedMovement:
            board.checkAndHandleLineCompletion()
        case .lineCompleted(let completion):
            boardVisualizer.handleLineCompletion(completion)
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
