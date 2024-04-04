//
//  SKButton.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/4/24.
//

import Foundation

import SpriteKit

class SKButton: SKNode {
    var label: SKLabelNode
    var background: SKShapeNode
    var alphaComponent: CGFloat
    var action: (() -> Void)?

    init(text: String, fontSize: CGFloat = 20, width: CGFloat = 150, height: CGFloat = 50, backgroundColor: UIColor = .blue, alphaComponent: CGFloat = 1.0) {
        self.alphaComponent = alphaComponent
        
        label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = fontSize
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.fontColor = .white

        background = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        background.fillColor = backgroundColor.withAlphaComponent(alphaComponent)
        background.strokeColor = backgroundColor

        super.init()

        isUserInteractionEnabled = true

        addChild(background)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.fillColor = background.fillColor.withAlphaComponent(alphaComponent - 0.2)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.fillColor = background.fillColor.withAlphaComponent(alphaComponent)
        action?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        background.fillColor = background.fillColor.withAlphaComponent(1.0)
    }
}
