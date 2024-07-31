//
//  PlayViewModel.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/14/24.
//

import Foundation
import Combine
import SpriteKit

class PlayViewModel: ObservableObject {
    @Published private(set) var score: Int = 0
    @Published private(set) var remainingTime: String = ""
    @Published public var showMenuButtons: Bool = true
    @Published public var showEndGameScreen: Bool = false
    @Published public var menuButtonsScale: CGFloat = 0.0

    public let hudFontSize: CGFloat = 24
    public let menuOffset: CGFloat = -90

    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()

    init(gameManager: GameManager) {
        self.gameManager = gameManager
        subscribeToScore()
        subscribeToTime()
        subscribeToGameState()
    }

    // MARK: Public

    public func configureGameScreen(size: CGSize) {
        gameManager.configureSceneSize(size: size)
    }
    
    public func getGameScene() -> SKScene {
        return gameManager.getScene()
    }
    
    public func playButtonTapped() {
        gameManager.playButtonTapped()
    }
    
    func getGameEndPopupViewModel() -> GameEndPopupViewModel {
        return GameEndPopupViewModel(playAgainAction: playAgainTapped)
    }

    // MARK: Subscriptions
    
    private func subscribeToGameState() {
        gameManager.state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .uninitialized: return
                case .loading: return
                case .loaded: return
                case .playing: return
                case .paused: return
                case .ended:
                    self?.showEndGameScreen = true
                case .startSequnce:
                    return
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToScore() {
        gameManager.scorePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newScore in
                self?.score = newScore
            }
            .store(in: &cancellables)
    }

    private func subscribeToTime() {
        gameManager.timePublisher
            .receive(on: RunLoop.main)
            .throttle(for: .milliseconds(20), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] newTime in
                self?.updateTimeRemaining(with: newTime)
            }
            .store(in: &cancellables)
    }
    
    // MARK: Helpers
    
    private func updateTimeRemaining(with timeRemaining: TimeInterval) {
        remainingTime = String(format: "%.2f", timeRemaining)
    }
    
    private func playAgainTapped() {
        gameManager.playAgainTapped()
    }
}
