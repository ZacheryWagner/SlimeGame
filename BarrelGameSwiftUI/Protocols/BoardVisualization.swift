//
//  BoardVisualization.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation
import Combine

protocol BoardVisualizing {
    var events: PassthroughSubject<GameEvent, Never> { get set }

    func update(for board: Board, in rect: CGRect, center: CGPoint)
}
