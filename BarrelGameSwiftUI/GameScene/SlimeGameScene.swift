//
//  SlimeGameScene.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation
import SpriteKit
import Combine

class SlimeGameScene: SKScene {
    private let logger = Logger(source: SlimeGameScene.self)
    
    /// Informs the `GameManager` of  `GameEvent`s
    public var events = PassthroughSubject<GameEvent, Never>()
    
    private var bgGrass = SKSpriteNode(imageNamed: "ruins_bg_grass")
    private var bgWater = SKSpriteNode(imageNamed: "ruins_bg_water")
    private var fgGrass = SKSpriteNode(imageNamed: "ruins_fg_grass")
    private var fgLeaves = SKSpriteNode(imageNamed: "ruins_fg_leaves")
    private var gbStone = SKSpriteNode(imageNamed: "ruins_gb_stone")
    
    internal lazy var gbPlayableArea: SKSpriteNode = {
        var texture = SKTexture(imageNamed: "ruins_gb_playable_area")
        return SKSpriteNode(texture: texture, size: texture.size())
    }()
    
    internal var slimeMatrix = [[Slime?]]()

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
        setupWorld()
    }
    
    public func setupWorld() {
        setupBackground()
        setupForeground()
        setupGamebox()
        
        setupDebugUI()
        
        events.send(.playableAreaSetupComplete(gbPlayableArea.frame, CGPoint(x: frame.midX, y: frame.midY + 20)))
    }
    
    public func inject(slimes: [[Slime?]]) {
        logger.info("inject")
        slimeMatrix = slimes
        for row in slimes.indices {
            for column in slimes.indices {
                if let slime = slimeMatrix[row][column] {
                    addChild(slime)
                }
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupBackground() {
        bgGrass.position = frame.center
        bgGrass.zPosition = LayerPositions.bgGrass.rawValue
        
        bgWater.position = frame.center
        bgWater.zPosition = LayerPositions.bgWater.rawValue
        
        addChild(bgGrass)
        addChild(bgWater)
    }
    
    private func setupForeground() {
        fgGrass.position = frame.center
        fgGrass.zPosition = LayerPositions.fgGrass.rawValue
        
        fgLeaves.position = frame.center
        fgLeaves.zPosition = LayerPositions.fgLeaves.rawValue
        
        addChild(fgGrass)
        addChild(fgLeaves)
        
        fgLeaves.run(wiggleAction())
    }
    
    private func setupGamebox() {
        gbStone.position = frame.center
        gbStone.zPosition = LayerPositions.gamebox.rawValue
        
        gbPlayableArea.position = frame.center
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
