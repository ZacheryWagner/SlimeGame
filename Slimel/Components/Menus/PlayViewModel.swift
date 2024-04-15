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
    @Published private(set) var remainingTime: TimeInterval = Constants.startTime
    @Published public var isButtonsHidden: Bool = true
    @Published public var scale: CGFloat = 0.0
    
    public private(set) var hudFontSize: CGFloat = 24

    private let gameManager: GameManager
    private var cancellables = Set<AnyCancellable>()

    init(gameManager: GameManager) {
        self.gameManager = gameManager
        subscribeToScore()
        subscribeToTime()
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

    // MARK: Subscriptions
    
    private func subscribeToScore() {
        gameManager.scorePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newScore in
                self?.score = newScore
            }
            .store(in: &cancellables)
    }

    private func subscribeToTime() {
        gameManager.timePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTime in
                self?.remainingTime = newTime
            }
            .store(in: &cancellables)
    }
}
