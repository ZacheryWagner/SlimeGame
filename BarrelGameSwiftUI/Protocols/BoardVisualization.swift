//
//  BoardVisualization.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation

protocol BoardVisualizing {
    var updateDelegate: BoardVisualizerDelegate? { get set }
    
    func update(for board: Board, in rect: CGRect)
}
