//
//  DirectionalMovement.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation

protocol DirectionalTextures {
    func updateTexture(in direction: Direction)
    func updateTextureToIdle()
}

enum Direction: String, CaseIterable {
    case up
    case down
    case left
    case right
    
    var isHorizontal: Bool {
        return self == .left || self == .right
    }
    
    public mutating func flip() {
        switch self {
        case .up:
            self = .down
        case .down:
            self = .up
        case .left:
            self = .right
        case .right:
            self = .left
        }
    }
}
