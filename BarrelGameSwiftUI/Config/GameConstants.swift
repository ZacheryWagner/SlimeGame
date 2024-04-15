//
//  Constants.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/2/24.
//

import Foundation

struct Constants {

    /// Number of slime rows
    static let rows: Int = 6
    
    /// Number of slime clolumns
    static let columns: Int = 6
    
    /// Number of real pixels per pixel art pixel
    static let pixelWidth: CGFloat = 4
    
    /// Pixels between slimes
    static let slimePadding: CGFloat = pixelWidth * 1
    
    static let slimeMoveBounceScale: CGFloat = 1.2
    static let slimeSpawnBounceScale: CGFloat = 1.25
    
    static let slimeMoveDuration: CGFloat = 0.15
    static let slimeSpawnDuration: CGFloat = 0.4
    static let slimeDespawnDuration: CGFloat = 0.35
    
    /// These need to go away once I get corrected assets
    static let playableAreaSize = CGSize(width: 310, height: 404)
    static let playableAreaVerticalOffset: CGFloat = 20
    
    static let startTime: TimeInterval = 60
}
