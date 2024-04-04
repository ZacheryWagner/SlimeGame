//
//  ContentView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let gameManager = GameManagerFactory.make()
    
    init() {}
    
    var body: some View {
        GeometryReader { geometry in
            gameManager.getSpriteView()
        }
        .onAppear {
            let screenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            gameManager.configureSceneSize(size: screenSize)
        }
    }
}

#Preview {
    ContentView()
}
