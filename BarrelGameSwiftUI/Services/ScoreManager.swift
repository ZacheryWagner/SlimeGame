//
//  ScoreManager.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/14/24.
//

import Foundation
import Combine

class ScoreManager: ScoreTracking {
    private let logger = Logger(source: ScoreManager.self)
    
    private var score = 0 {
        didSet {
            scoreSubject.send(score)
        }
    }
    
    // MARK: ScoreTracking

    var scoreSubject = CurrentValueSubject<Int, Never>(0)

    func addScoreForLineCompletion(comboLevel: Int, lineClears: Int) {
        logger.info("addScoreForLineCompletion comboLevel: \(comboLevel), lineClears: \(lineClears)")
        let baseScorePerLine = ScoreConstants.standardScoreIncrement
        let lineScore = baseScorePerLine + (lineClears * ScoreConstants.lineClearMultiplier) * baseScorePerLine
        let comboScore = Double(lineScore) * (1 + Double(comboLevel - 1) * ScoreConstants.comboMultiplier)
        
        // The final score to add for this event
        let scoreToAdd = Int(comboScore)
        
        // Increment total score
        score += scoreToAdd
    }
}
