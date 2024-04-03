//
//  ContentView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let scene = SlimeGameScene()
    
    init() {
        scene.scaleMode = .fill
    }
    
    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .onAppear {
            // Update the scene's size based on the actual screen dimensions
            scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }
    }
}

#Preview {
    ContentView()
}
