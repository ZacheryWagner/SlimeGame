//
//  Silme.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation
import SpriteKit

class Slime: SKSpriteNode, DirectionalMovement {
    
    // MARK: Types
    
    enum Genus: String {
        case red
        case blue
    }

    // MARK: Properties
    
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

    func move(in direction: Direction) {
        texture = directionalTextures[direction]
        
        let moveDistance: CGFloat = 10
        var moveAction: SKAction?
        
        switch direction {
        case .up:
            moveAction = SKAction.moveBy(x: 0, y: moveDistance, duration: 0.2)
        case .down:
            moveAction = SKAction.moveBy(x: 0, y: -moveDistance, duration: 0.2)
        case .left:
            moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: 0.2)
        case .right:
            moveAction = SKAction.moveBy(x: moveDistance, y: 0, duration: 0.2)
        }
        
        if let action = moveAction {
            run(action) { [weak self] in
                guard let self = self else { return }
                self.texture = self.idleTexture
            }
        }
    }
}
