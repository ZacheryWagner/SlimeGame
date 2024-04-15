//
//  SKSpriteNode.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation
import SpriteKit

extension SKSpriteNode {
    // Scale the sprite to fit the screen width while maintaining its aspect ratio
    func scaleToFitScreenWidth() {
        let aspectRatio = self.size.height / self.size.width
        let screenWidth = UIScreen.main.bounds.width
        self.size.width = screenWidth
        self.size.height = screenWidth * aspectRatio
    }

    // Scale the sprite to fit the screen height while maintaining its aspect ratio
    func scaleToFitScreenHeight() {
        let aspectRatio = self.size.width / self.size.height
        let screenHeight = UIScreen.main.bounds.height
        self.size.height = screenHeight
        self.size.width = screenHeight * aspectRatio
    }
}
