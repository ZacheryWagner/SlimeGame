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
    private var timer: Timer?
    private let timeBonusPerLine = 5.0 // seconds
    private(set) var timeSubject = CurrentValueSubject<TimeInterval, Never>(0)

    init(initialTime: TimeInterval = Constants.startTime) {
        self.timeLeft = initialTime
        timeSubject.send(timeLeft)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.timeLeft -= 1
            if self.timeLeft <= 0 {
                self.stopTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func addTimeForLineCompletion() {
        logger.info("addTimeForLineCompletion")
        timeLeft += timeBonusPerLine
    }
}
