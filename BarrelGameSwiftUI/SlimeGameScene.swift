//
//  SlimeGameScene.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation
import SpriteKit

protocol SlimeGameSceneDelegate: AnyObject {
    func didSetupPlayableArea(with frame: CGRect)
}

class SlimeGameScene: SKScene {
    private var bgGrass = SKSpriteNode(imageNamed: "ruins_bg_grass")
    private var bgWater = SKSpriteNode(imageNamed: "ruins_bg_water")
    private var fgGrass = SKSpriteNode(imageNamed: "ruins_fg_grass")
    private var fgLeaves = SKSpriteNode(imageNamed: "ruins_fg_leaves")
    private var gbStone = SKSpriteNode(imageNamed: "ruins_gb_stone")
    private var gbPlayableArea = SKSpriteNode(imageNamed: "ruins_gb_playable_area")
    
    weak var setupDelegate: SlimeGameSceneDelegate?

    // MARK: Lifecycle
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {

    }
    
    public func setupWorld() {
        setupBackground()
        setupForeground()
        setupGamebox()
        
        setupDelegate?.didSetupPlayableArea(with: gbPlayableArea.frame)
    }
    
    public func inject(slimes: [[Slime?]]) {
        for row in slimes.indices {
            for column in slimes.indices {
                if let slime = slimes[row][column] {
                    addChild(slime)
                }
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        bgGrass.position = CGPoint(x: frame.midX, y: frame.midY)
        bgGrass.zPosition = LayerPositions.bgGrass.rawValue
        
        bgWater.position = CGPoint(x: frame.midX, y: frame.midY)
        bgWater.zPosition = LayerPositions.bgWater.rawValue
        
        addChild(bgGrass)
        addChild(bgWater)
    }
    
    private func setupForeground() {
        fgGrass.position = CGPoint(x: frame.midX, y: frame.midY)
        fgGrass.zPosition = LayerPositions.fgGrass.rawValue
        
        fgLeaves.position = CGPoint(x: frame.midX, y: frame.midY)
        fgLeaves.zPosition = LayerPositions.fgLeaves.rawValue
        
        addChild(fgGrass)
        addChild(fgLeaves)
        
        fgLeaves.run(wiggleAction())
    }
    
    private func setupGamebox() {
        gbStone.position = CGPoint(x: frame.midX, y: frame.midY)
        gbStone.zPosition = LayerPositions.gamebox.rawValue
        
        gbPlayableArea.position = CGPoint(x: frame.midX, y: frame.midY)
        gbPlayableArea.zPosition = LayerPositions.gamebox.rawValue
        
        addChild(gbStone)
        addChild(gbPlayableArea)
    }
    
    // MARK: Actions

    private func wiggleAction() -> SKAction {
        let moveRight = SKAction.moveBy(x: 5, y: 0, duration: 2)
        let moveLeft = SKAction.moveBy(x: -5, y: 0, duration: 2)
        let moveSequence = SKAction.sequence([moveRight, moveLeft])

        let rotateRight = SKAction.rotate(byAngle: 0.02, duration: 2)
        let rotateLeft = SKAction.rotate(byAngle: -0.02, duration: 2)
        let rotateSequence = SKAction.sequence([rotateRight, rotateLeft])

        let group = SKAction.group([moveSequence, rotateSequence])
        let repeatForever = SKAction.repeatForever(group)

        return repeatForever
    }
}

extension SlimeGameScene {
    enum LayerPositions: CGFloat {
        case bgGrass = -10
        case bgWater = -9
        case gamebox = 0
        case slime = 1
        case fgGrass = 10
        case fgLeaves = 11
    }
}
