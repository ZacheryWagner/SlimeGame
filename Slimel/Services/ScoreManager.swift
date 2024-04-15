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

        // Adjust line score calculation to account for multiple lines
        let additionalLinesScore = (lineClears > 1) ? (lineClears - 1) * ScoreConstants.lineClearMultiplier * baseScorePerLine : 0
        let lineScore = baseScorePerLine + additionalLinesScore

        // Combo score should not apply if comboLevel is 0
        let comboMultiplier = comboLevel > 0 ? (1 + Double(comboLevel - 1) * ScoreConstants.comboMultiplier) : 1.0

        // Calculate final score to add
        let comboScore = Double(lineScore) * comboMultiplier
        let scoreToAdd = Int(comboScore)
        
        // Increment total score
        score += scoreToAdd
    }
}
