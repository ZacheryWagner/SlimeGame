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
    private var gbPlayableArea = SKSpriteNode(imageNamed: "ruins_gb_playable_area")
    
    internal var playableArea = SKSpriteNode(color: .clear, size: Constants.playableAreaSize)
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
    
    // MARK: Public

    public func inject(slimes: [[Slime?]]) {
        logger.info("inject slimes")
        slimeMatrix = slimes
        var delayIncrement = 0.0
        
        for row in slimes.indices {
            for column in slimes[row].indices {
                if let slime = slimeMatrix[row][column] {
                    // Start the slime at a small scale
                    slime.setScale(0)
                    addChild(slime)
                    animateAddSlime(slime: slime, delayIncrement: &delayIncrement)
                }
            }
        }
    }
    
    // MARK: Setup
    
    private func setupWorld() {
        setupBackground()
        setupForeground()
        setupGamebox()
        
        setupDebugUI()
        
        events.send(.playableAreaSetupComplete(
            playableArea.frame,
            CGPoint(x: frame.midX, y: frame.midY + Constants.playableAreaVerticalOffset))
        )
    }
    
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
        playableArea.position = CGPoint(x: frame.midX, y: frame.midY + 20)

        gbStone.position = frame.center
        gbStone.zPosition = LayerPositions.gamebox.rawValue
        
        gbPlayableArea.position = frame.center
        gbPlayableArea.zPosition = LayerPositions.gamebox.rawValue
        
        addChild(gbStone)
        addChild(gbPlayableArea)
    }
    
    // MARK: Animations
    
    private func animateAddSlime(slime: Slime, delayIncrement: inout Double) {
        let scaleUpAction = SKAction.scale(to: 1.25, duration: 0.25)
        let scaleDownAction = SKAction.scale(to: 1.0, duration: 0.15)
        
        // Increment the delay for each slime based on its position
        let delayAction = SKAction.wait(forDuration: 0.05 * delayIncrement)
        
        // Combine the actions into a sequence for the bounce effect
        let bounceSequence = SKAction.sequence([scaleUpAction, scaleDownAction])
        let sequence = SKAction.sequence([delayAction, bounceSequence])
        
        // Run the sequence on the slime
        slime.run(sequence)
        
        // Increment the delay for the next slime
        delayIncrement += 1
    }

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
    
    // MARK: Touch
    
    private var touchStartPoint: CGPoint?
    private var touchStartRow: Int?
    private var touchStartColumn: Int?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self) // Get touch location in the scene

        // Calculate the touch's position relative to the playableArea's coordinate space
        let localX = location.x - (playableArea.position.x - playableArea.size.width / 2)
        let localY = (playableArea.position.y + playableArea.size.height / 2) - location.y

        // Ensure the touch is within the playableArea
        if localX >= 0, localX <= playableArea.size.width, localY >= 0, localY <= playableArea.size.height {
            let columnWidth = playableArea.size.width / CGFloat(Constants.columns)
            let rowHeight = playableArea.size.height / CGFloat(Constants.rows)

            let touchedColumn = Int(localX / columnWidth)
            let touchedRow = Int(localY / rowHeight)

            touchStartPoint = location
            touchStartRow = touchedRow
            touchStartColumn = touchedColumn
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = touchStartPoint, let touch = touches.first,
              let startRow = touchStartRow, let startColumn = touchStartColumn else { return }
        let endLocation = touch.location(in: self)

        // Determine the swipe direction
        let deltaX = endLocation.x - start.x
        let deltaY = endLocation.y - start.y

        if abs(deltaX) > abs(deltaY) {
            // Horizontal Swipe
            if deltaX > 0 {
                events.send(.swipe(.right, startRow))
            } else {
                events.send(.swipe(.left, startRow))
            }
        } else {
            // Vertical Swipe
            if deltaY > 0 {
                events.send(.swipe(.up, startColumn)) // deltaY > 0 indicates a swipe downwards on the screen
            } else {
                events.send(.swipe(.down, startColumn)) // deltaY < 0 indicates a swipe upwards
            }
        }

        // Reset for next touch
        touchStartPoint = nil
        touchStartRow = nil
        touchStartColumn = nil
    }
}
