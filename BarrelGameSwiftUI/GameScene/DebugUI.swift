//
//  DebugUI.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/4/24.
//

import Foundation
import SpriteKit

extension SlimeGameScene {
    private var debugLabel: SKLabelNode {
        let label = SKLabelNode(text: "DEBUG MODE")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 18
        label.color = .white
        label.zPosition = LayerPositions.UI.rawValue
        label.position = CGPoint(x: frame.midX, y: frame.midY + 270)
        return label
    }
    
    private var debugSlime: Slime {
        let slime = Slime(genus: .red)
        slime.position = frame.center
        slime.zPosition = LayerPositions.slime.rawValue
        return slime
    }
    
    private var debugCenterMarker: SKShapeNode {
        let marker = SKShapeNode(circleOfRadius: 5)
        marker.fillColor = SKColor.red
        marker.position = frame.center
        
        marker.zPosition = 10
        return marker
    }
    
    private var generateBoardButton: SKButton {
        let button = SKButton(
            text: "Generate Board",
            fontSize: 24,
            width: 200,
            height: 60,
            backgroundColor: .red,
            alphaComponent: 0.9)
        button.action = { [weak self] in
            guard let self = self else { return }
            
            self.removeChildren(in: slimeMatrix.flatMap({ $0 }).compactMap({ $0 }))

            events.send(.playableAreaSetupComplete(
                gbPlayableArea.frame,
                CGPoint(x: frame.midX, y: frame.midY + 20))
            )
        }
        button.position = CGPoint(x: frame.midX, y: 60)
        button.zPosition = LayerPositions.UI.rawValue
        return button
    }
    
    public func setupDebugUI() {
        addChild(debugCenterMarker)
        addChild(debugSlime)
        addChild(debugLabel)
        addChild(generateBoardButton)
        drawPlayableArea()
    }
    
    private func drawPlayableArea() {
        // Assuming gbPlayableArea's anchorPoint is (0.5, 0.5)
        let gbFrame = gbPlayableArea.frame
        let path = CGMutablePath()
        path.addRect(gbFrame)
        
        // Use the path to create a shape node
        let playableAreaOutline = SKShapeNode(path: path)
        playableAreaOutline.strokeColor = SKColor.green
        playableAreaOutline.lineWidth = 6
        playableAreaOutline.fillColor = SKColor.clear
        
        // Since we're adding this directly to the scene, we don't need to convert points
        addChild(playableAreaOutline)
    }
}
