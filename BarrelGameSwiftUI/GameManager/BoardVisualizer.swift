//
//  BoardVisualizer.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation
import Combine
import SpriteKit

protocol BoardVisualizerDelegate: AnyObject {
    func didUpdateSlimes(_ slimes: [[Slime?]])
}

class BoardVisualizer: BoardVisualizing {
    // MARK: Properties
    
    /// Informs the `GameManager` of  `GameEvent`s
    public var events = PassthroughSubject<GameEvent, Never>()
    
    private var slimes = [[Slime?]]()
    
    private let sampleSlime = Slime(genus: .red)
    
    private var startX: CGFloat = 0
    private var startY: CGFloat = 0
    private var center: CGPoint?
        
    init() {}
    
    // MARK: BoardVisualizing
    
    public func update(for board: Board, center: CGPoint) {
        self.center = center

        // Clear existing slimes
        slimes = Array(repeating: Array(repeating: nil, count: Constants.columns), count: Constants.rows)

        // Calculate the total grid width and height to adjust positions accordingly
        let totalGridWidth = (sampleSlime.size.width + Constants.slimePadding) * CGFloat(Constants.columns - 1)
        let totalGridHeight = (sampleSlime.size.height + Constants.slimePadding) * CGFloat(Constants.rows - 1)

        // Calculate starting positions based on the center
        startX = center.x - (totalGridWidth / 2)
        startY = center.y + (totalGridHeight / 2)

        setSlimes(for: board)

        // Update delegate or scene with the newly positioned slimes
        events.send(GameEvent.boardVisualizationComplete(slimes))
    }
    
    // Animates slimes for a given swipe direction and index (row or column)
    func animateSlimesForSwipe(direction: Direction, index: Int) {
        switch direction {
        case .left, .right:
            animateSlimesInRow(index, direction: direction)
        case .up, .down:
            animateSlimesInColumn(index, direction: direction)
        }
    }
    
    // MARK: Generation
    
    private func setSlimes(for board: Board) {
        for row in 0..<Constants.rows {
            for column in 0..<Constants.columns {
                let tileState = board.getTileState(row: row, column: column)
                if tileState != .empty {
                    let slime = Slime(genus: tileState == .red ? .red : .blue)

                    // Calculate the position for each slime relative to the center
                    let xPosition = startX + (sampleSlime.size.width + Constants.slimePadding) * CGFloat(column)
                    let yPosition = startY - (sampleSlime.size.height + Constants.slimePadding) * CGFloat(row)

                    slime.position = CGPoint(x: xPosition, y: yPosition)
                    slimes[row][column] = slime
                }
            }
        }
    }
    
    // MARK: Movement

    private func animateSlimesInRow(_ row: Int, direction: Direction) {
        guard row < slimes.count else { return }
        let slimesInRow = slimes[row]
        
        // Calculate new positions for each slime in the row
        let positions = calculateNewPositionsForSlimesInRow(row: row, direction: direction)

        // Animate each slime to its new position
        for (index, slime) in slimesInRow.enumerated() {
            guard let slime = slime else { continue }
            let newPosition = positions[index]
            let moveAction = SKAction.move(to: newPosition, duration: 0.25)
            slime.run(moveAction)
        }
    }

    private func animateSlimesInColumn(_ column: Int, direction: Direction) {
        guard column < slimes[0].count else { return }
        let positions = calculateNewPositionsForSlimesInColumn(column: column, direction: direction)

        // Animate each slime in the column to its new position
        for (row, slimeRow) in slimes.enumerated() {
            guard let slime = slimeRow[column] else { continue }
            let newPosition = positions[row]
            let moveAction = SKAction.move(to: newPosition, duration: 0.25)
            slime.run(moveAction)
        }
    }

    // Calculates new positions for all slimes in a specific row
    private func calculateNewPositionsForSlimesInRow(row: Int, direction: Direction) -> [CGPoint] {
        var positions = [CGPoint]()
        for column in 0..<Constants.columns {
            let newPosition = calculateNewPositionFor(row: row, column: column)
            positions.append(newPosition)
        }
        return direction == .left ? positions : positions.reversed()
    }

    // Calculates new positions for all slimes in a specific column
    private func calculateNewPositionsForSlimesInColumn(column: Int, direction: Direction) -> [CGPoint] {
        var positions = [CGPoint]()
        for row in 0..<Constants.rows {
            let newPosition = calculateNewPositionFor(row: row, column: column)
            positions.append(newPosition)
        }
        return direction == .up ? positions : positions.reversed()
    }

    // Calculates a single new position based on row and column
    private func calculateNewPositionFor(row: Int, column: Int) -> CGPoint {
        let xPosition = startX + (sampleSlime.size.width + Constants.slimePadding) * CGFloat(column)
        let yPosition = startY - (sampleSlime.size.height + Constants.slimePadding) * CGFloat(row)
        return CGPoint(x: xPosition, y: yPosition)
    }
}
