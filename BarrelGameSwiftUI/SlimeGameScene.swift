//
//  SlimeGameScene.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation
import SpriteKit

class SlimeGameScene: SKScene {
    private var animatedBackground: SKSpriteNode!
    
    private let bgTextureNames: [String] = ["bg_grass"]
    private var bgTextures = [SKTexture]()
    
    private var gamebox = SKSpriteNode(imageNamed: "gamebox_stone")
    private var slime = SKSpriteNode(imageNamed: "slime_green")
    private var slime2 = SKSpriteNode(imageNamed: "slime_red")
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        loadTextures()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func didMove(to view: SKView) {
        setupBackground()
        setupGamebox()
        setupSlimes()
    }
    
    // MARK: - Private
    
    private func setupBackground() {
        animatedBackground = SKSpriteNode(texture: bgTextures.first)
        animatedBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        animatedBackground.zPosition = LayerPositions.background.rawValue
        addChild(animatedBackground)
    }
    
    private func setupGamebox() {
        gamebox.position = CGPoint(x: frame.midX, y: frame.midY)
        gamebox.zPosition = LayerPositions.gamebox.rawValue
        addChild(gamebox)
    }
    
    private func setupSlimes() {
        slime.position = CGPoint(x: frame.midX - 32, y: frame.midY)
        slime.zPosition = LayerPositions.slime.rawValue
        
        slime2.position = CGPoint(x: frame.midX + 32, y: frame.midY)
        slime2.zPosition = LayerPositions.slime.rawValue
        addChild(slime)
        addChild(slime2)
    }
    
    private func loadTextures() {
        bgTextures = bgTextureNames.map { SKTexture(imageNamed: $0) }
    }

    private func animateBackground() {
        let animation = SKAction.animate(with: bgTextures, timePerFrame: 0.5)
        let loop = SKAction.repeatForever(animation)
        
        animatedBackground.run(loop)
    }
}

extension SlimeGameScene {
    enum LayerPositions: CGFloat {
        case background = -1
        case gamebox = 0
        case slime = 1
    }
}
