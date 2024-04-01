//
//  ContentView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var board = Board()
    let scene = SlimeGameScene()

    
    init() {
        scene.scaleMode = .fill
        board.generateGameReadyBoard()
        board.prettyPrintMatrix()
        board.moveUp(column: 1)
        board.prettyPrintMatrix()
        board.moveDown(column: 3)
        board.prettyPrintMatrix()
        board.moveUp(column: 0)
        board.prettyPrintMatrix()
        board.moveDown(column: 4)
        board.prettyPrintMatrix()
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
