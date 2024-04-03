//
//  BoardVisualizer.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation

protocol BoardVisualizerDelegate: AnyObject {
    func didUpdateSlimes(_ slimes: [[Slime?]])
}

class BoardVisualizer: BoardVisualizing {
    // MARK: Properties
    
    private var slimes: [[Slime?]] = Array(
        repeating: Array(repeating: nil, count: Constants.columns),
        count: Constants.rows)
    
    weak var updateDelegate: BoardVisualizerDelegate?
    
    init() {}
    
    // MARK: BoardVisualizing
    
    func update(for board: Board, in rect: CGRect) {
        
    }
    
    private func generateSlimes() {
        Logger.info("generateSlimes")

        updateDelegate?.didUpdateSlimes(slimes)
    }
}
