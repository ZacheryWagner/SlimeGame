//
//  SKSpriteNode.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/30/24.
//

import Foundation
import SpriteKit

extension SKSpriteNode {
    
    func scaleTo(screenWidthPercentage: CGFloat) {
        let aspectRatio = self.size.height / self.size.width
        self.size.width = ScreenSize.width * screenWidthPercentage
        self.size.height = self.size.width * aspectRatio
    }
    
    func scaleTo(screenHeightPercentage: CGFloat) {
        let aspectRatio = self.size.width / self.size.height
        self.size.height = ScreenSize.heigth * screenHeightPercentage
        self.size.width = self.size.height * aspectRatio
    }
}

struct ScreenSize {
    static let width = UIScreen.main.bounds.size.width
    static let heigth = UIScreen.main.bounds.size.height
    static let maxLength = max(ScreenSize.width, ScreenSize.heigth)
    static let minLength = min(ScreenSize.width, ScreenSize.heigth)
}
