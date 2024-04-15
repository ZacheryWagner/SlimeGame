//
//  Silme.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation
import SpriteKit

class Slime: SKSpriteNode, DirectionalTextures {
    // MARK: Types
    
    enum Genus: String {
        case red
        case blue
    }

    // MARK: Properties
    
    private let logger = Logger(source: Slime.self)
    
    private var idleTexture: SKTexture
    
    private var directionalTextures: [Direction: SKTexture] = [:]
    
    private let genus: Genus
    
    // MARK: Initialization
    
    init(genus: Genus) {
        self.genus = genus
        idleTexture = SKTexture(imageNamed: "slime_\(genus)_idle")
        super.init(texture: idleTexture, color: .clear, size: idleTexture.size())
        setupTextures()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setupTextures() {
        let textureNamePrefix = "slime_\(genus)"
        
        for direction in Direction.allCases {
            directionalTextures[direction] = SKTexture(imageNamed: "\(textureNamePrefix)_\(direction)")
        }
    }
    
    // MARK: DirectionalMovement
    
    func updateTexture(in direction: Direction) {
        texture = directionalTextures[direction]

    }
    func updateTextureToIdle() {
        texture = idleTexture
    }
}
