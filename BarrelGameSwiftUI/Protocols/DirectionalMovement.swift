//
//  DirectionalMovement.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation

protocol DirectionalMovement {
    func move(in direction: Direction)
}

enum Direction: String, CaseIterable {
    case up
    case down
    case left
    case right
}
