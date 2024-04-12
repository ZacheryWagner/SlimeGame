//
//  ContentView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    // MARK: Properties
    
    private let gameManager = GameManagerFactory.make()
    private let offset: CGFloat = -35

    @State private var scale: CGFloat = 0.0
    @State private var buttonsVisible: Bool = true

    init() {}
    
    // MARK: Views

    var body: some View {
        ZStack {
            gameView()
            if buttonsVisible {
                mainUI()
            }
        }
        .onAppear {
            setupGame()
            animateButtons()
        }
    }

    private func gameView() -> some View {
        GeometryReader { geometry in
            gameManager.getSpriteView()
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func mainUI() -> some View {
        let buttonHeight: CGFloat = 80
        let buttonWidth: CGFloat = 200
        let buttonStyle = ThreeDimensionalButtonStyle(
            topColor: Color(.slimelRedTop),
            undersideColor: Color(.slimelRed),
            fontSize: 24)

        return VStack(spacing: 30) {
            Button("Play") {
                animateButtonsOut()
                gameManager.playButtonTapped()
            }
            .buttonStyle(buttonStyle)
            .frame(width: buttonWidth, height: buttonHeight)
            .scaleEffect(scale)
            
            Button("Zen Mode") {}
                .buttonStyle(buttonStyle)
                .frame(width: buttonWidth, height: buttonHeight)
                .scaleEffect(scale)
            
            Button("Shop") {}
                .buttonStyle(buttonStyle)
                .frame(width: buttonWidth, height: buttonHeight)
                .scaleEffect(scale)
        }
        .offset(y: offset)
    }
    
    // MARK: Helpers

    private func setupGame() {
        let screenSize = UIScreen.main.bounds.size
        gameManager.configureSceneSize(size: screenSize)
    }

    private func animateButtons() {
        withAnimation(.easeIn(duration: 0.25)) {
            scale = 1.2
        }
        withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.5).delay(0.2)) {
            scale = 1.0
        }
    }
    
    private func animateButtonsOut() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            buttonsVisible = false
        }
    }
}

// MARK: Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
