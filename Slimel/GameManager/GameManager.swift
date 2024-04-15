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
    
    // MARK: Combine
    
    private var state = CurrentValueSubject<GameState, Never>(.uninitialized)
    
    var scorePublisher: AnyPublisher<Int, Never> {
        scoreManager.scoreSubject.eraseToAnyPublisher()
    }
    
    var timePublisher: AnyPublisher<TimeInterval, Never> {
        timeManager.timeSubject.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Dependencies
    
    private var scoreManager: ScoreManager
    private var timeManager: TimeManager
    private var scene: SlimeGameScene
    private let board: Board
    private var boardVisualizer: BoardVisualizing

    // MARK: Initialization
    
    init(scene: SlimeGameScene, board: Board, boardVisualizer: BoardVisualizing, scoreManager: ScoreManager, timeManager: TimeManager) {
        self.scene = scene
        self.board = board
        self.boardVisualizer = boardVisualizer
        self.scoreManager = scoreManager
        self.timeManager = timeManager
        
        self.scene.scaleMode = .aspectFill

        state.send(.loading)
    
        setupEvents()
        setupStateSubscription()
        subscribeToTimeManager()
    }

    private func setupEvents() {
        scene.events
            .merge(with: boardVisualizer.events)
            .merge(with: board.events)
            .sink { [weak self] event in
                self?.handleGameEvent(event)
            }
            .store(in: &cancellables)
    }
    
    
    // Subscribing to the timeManager's time updates
    private func subscribeToTimeManager() {
        timeManager.timeSubject
            .sink { [weak self] timeLeft in
                if timeLeft <= 0 {
                    self?.end()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: State Machine
    
    private func setupStateSubscription() {
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

    private func handleGameEvent(_ event: GameEvent) {
        logger.info("handleGameEvent: \(event.localizedDescription)")
        switch event {
        case .playableAreaSetupComplete(_, let center):
            boardVisualizer.setup(for: center)
//            boardVisualizer.startMenuSequence()
        case .boardVisualizationComplete(let slimes):
            scene.inject(slimeMatrix: slimes)
            state.send(.ready)
        case .swipe(let direction, let index):
            board.move(direction: direction, index: index)
            boardVisualizer.animateSlimesForSwipe(
                direction: direction,
                index: index)
        case .slimesFinishedMovement:
            board.checkAndHandleLineCompletion()
        case .linesCompleted(let completions):
            boardVisualizer.handleLineCompletions(completions)
            scoreManager.addScoreForLineCompletion(comboLevel: 0, lineClears: completions.count)
            timeManager.addTimeForLineCompletion()
        case .slimesFinishedDespawning(let completion):
            let lineRegenInfo = board.generateNewLine(for: completion)
            boardVisualizer.generateNewSlimes(from: lineRegenInfo)
        case .newSlimesPrepared(let slimes):
            scene.inject(slimes: slimes)
        }
    }
    
    private func transition(to newState: GameState) {
        guard state.value != newState else { return }
        state.send(newState)
    }

    // MARK: Game
    
    private func initializeGame() {
        logger.info("initializeGame")
        board.generateGameReadyBoard()
        boardVisualizer.createSlimes(for: board)
        start()
    }
    
    private func start() {
        guard state.value == .ready else { return }
        timeManager.startTimer()
    }
    
    
    // Handling the end of the game
    func end() {
        logger.info("end")
        state.send(.ended)
    }
    
    // MARK: Public
    
    public func playButtonTapped() {
        initializeGame()
    }
    
    public func getScene() -> SlimeGameScene {
        return scene
    }
    
    public func configureSceneSize(size: CGSize) {
        scene.size = size
    }
}
