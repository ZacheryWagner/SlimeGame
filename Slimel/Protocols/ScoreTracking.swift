//
//  ScoreTracking.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/14/24.
//

import Combine

protocol ScoreTracking {
    var scoreSubject: CurrentValueSubject<Int, Never> { get set }
    func addScoreForLineCompletion(comboLevel: Int, lineClears: Int)
}
