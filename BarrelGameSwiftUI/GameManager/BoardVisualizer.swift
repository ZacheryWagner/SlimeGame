//
//  BoardVisualizer.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation
import Combine

protocol BoardVisualizerDelegate: AnyObject {
    func didUpdateSlimes(_ slimes: [[Slime?]])
}

class BoardVisualizer: BoardVisualizing {
    // MARK: Properties
    
    /// Informs the `GameManager` of  `GameEvent`s
    public var events = PassthroughSubject<GameEvent, Never>()
    
    private var slimes = [[Slime?]]()
        
    init() {}
    
    // MARK: BoardVisualizing
    
    func update(for board: Board, in rect: CGRect, center: CGPoint) {
        let padding: CGFloat = Constants.slimePadding
        let sampleSlime = Slime(genus: .red)
        
        // Clear existing slimes
        slimes = Array(repeating: Array(repeating: nil, count: Constants.columns), count: Constants.rows)

        // Calculate the total grid width and height to adjust positions accordingly
        let totalGridWidth = (sampleSlime.size.width + padding) * CGFloat(Constants.columns - 1)
        let totalGridHeight = (sampleSlime.size.height + padding) * CGFloat(Constants.rows - 1)

        // Calculate starting positions based on the center
        let startX = center.x - (totalGridWidth / 2)
        let startY = center.y + (totalGridHeight / 2) // Start from top, moving downwards

        for row in 0..<Constants.rows {
            for column in 0..<Constants.columns {
                let tileState = board.getTileState(row: row, column: column)
                if tileState != .empty {
                    let slime = Slime(genus: tileState == .red ? .red : .blue)

                    // Calculate the position for each slime relative to the center
                    let xPosition = startX + (sampleSlime.size.width + padding) * CGFloat(column)
                    let yPosition = startY - (sampleSlime.size.height + padding) * CGFloat(row)

                    slime.position = CGPoint(x: xPosition, y: yPosition)
                    slimes[row][column] = slime
                }
            }
        }

        // Update delegate or scene with the newly positioned slimes
        events.send(GameEvent.boardVisualizationComplete(slimes))
    }
}
