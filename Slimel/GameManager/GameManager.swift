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
    
    public var state = CurrentValueSubject<GameState, Never>(.uninitialized)
    
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

        subscribeToSetupEvents()
        subscribeToGameEvents()
        setupStateSubscription()
        subscribeToTimeManager()
        transition(to: .loading)
    }
    
    // MARK: Setup Subscriptions

    private func subscribeToSetupEvents() {
        scene.setupEvents
            .merge(with: boardVisualizer.setupEvents)
            .sink { [weak self] event in
                self?.handleSetupEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToGameEvents() {
        scene.gameEvents
            .merge(with: board.gameEvents)
            .merge(with: boardVisualizer.gameEvents)
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
                    self?.transition(to: .ended)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: State Machines

    private func setupStateSubscription() {
        state
            .removeDuplicates()
            .sink { [weak self] newState in
                self?.logger.info("State Update: \(newState)")
                switch newState {
                case .uninitialized: return
                case .loading: self?.load()
                case .loaded: return
                case .startSequnce: self?.startSequence()
                case .playing: return
                case .paused: return
                case .ended: return
                }
            }
            .store(in: &cancellables)
    }

    private func transition(to newState: GameState) {
        guard state.value != newState else { return }
        state.send(newState)
    }
    
    // MARK: Event Handling
    
    private func handleSetupEvent(_ event: SetupEvent) {
        logger.info("handleSetupEvent: \(event.localizedDescription)")
        switch event {
        case .playableAreaSetupComplete(_, let center):
            boardVisualizer.setup(for: center)
            transition(to: .loaded)
        case .boardVisualizationComplete(let slimes):
            scene.injectPreGame(slimeMatrix: slimes)
        case .slimeSpawnFinished:
            start()
        }
    }

    private func handleGameEvent(_ event: GameEvent) {
        logger.info("handleGameEvent: \(event.localizedDescription)")
        switch event {
        case .move(let direction, let index):
            board.move(direction: direction, index: index)
            boardVisualizer.animateSlimesForSwipe(
                direction: direction,
                index: index)
        case .movementFinished:
            board.checkAndHandleLineCompletion()
        case .linesCompleted(let completions):
            boardVisualizer.handleLineCompletions(completions)
            scoreManager.addScoreForLineCompletion(comboLevel: 0, lineClears: completions.count)
            timeManager.addTimeForLineCompletion()
        case .slimeDespawnFinished(let completion):
            // This affects the matrix within the board itself
            let lineRegenInfo = board.generateNewLine(for: completion)
            boardVisualizer.generateNewSlimes(from: lineRegenInfo)
        case .newSlimesPrepared(let slimes):
            scene.injectDuringGame(slimes: slimes)
        case .slimeSpawnFinished:
            board.checkAndHandleLineCompletion()
        }
    }

    // MARK: Game
    
    /// Once the world is loaded `playableAreaSetupComplete` is fired.
    private func load() {
        board.generateGameReadyBoard()
//        scene.setupWorld()
    }

    
    /// Reset the timer and create the slimes.  
    /// When the slimes are finished being created they will call `boardVisualizationComplete` will be called.
    /// When they are finished spawning `slimesFinishedSpawning` will be hit
    private func startSequence() {
        timeManager.resetTimer()
        boardVisualizer.createSlimes(for: board)
    }

    private func start() {
        timeManager.startTimer()
        // Handle Go animation
    }
    
    private func end() {
        
    }
    
    // MARK: Public
    
    public func playButtonTapped() {
    }
    
    public func playAgainTapped() {
    }
    
    public func getScene() -> SlimeGameScene {
        return scene
    }
    
    public func configureSceneSize(size: CGSize) {
        scene.size = size
    }
}
