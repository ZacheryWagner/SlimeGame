//
//  TimeManager.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/14/24.
//

import Foundation

import Combine

class TimeManager {
    private let logger = Logger(source: TimeManager.self)
    
    private var timeLeft: TimeInterval {
        didSet {
            timeSubject.send(timeLeft)
        }
    }
    private var initialTime: TimeInterval = Constants.startTime
    private var timer: Timer?
    private let timeBonusPerLine = 5.0
    private(set) var timeSubject = CurrentValueSubject<TimeInterval, Never>(0)

    init(initialTime: TimeInterval = Constants.startTime) {
        self.initialTime = initialTime
        self.timeLeft = initialTime
    }
    
    // MARK: Public

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.handleTimerUpdate()
        }
    }

    func addTimeForLineCompletion() {
        logger.info("addTimeForLineCompletion")
        timeLeft += timeBonusPerLine
    }
    
    func resetTimer() {
        timeLeft = initialTime
        timeSubject.send(timeLeft)
    }
    
    // MARK: Private
    
    private func handleTimerUpdate() {
        timeLeft -= 0.01
        if timeLeft <= 0 {
            handleTimerFinished()
        } else {
            timeSubject.send(self.timeLeft)
        }
    }
    
    private func handleTimerFinished() {
        timeLeft = 0
        timer?.invalidate()
        timer = nil
        timeSubject.send(completion: .finished)
    }
}
