//
//  PlayView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import Combine
import SwiftUI
import SpriteKit

struct PlayView: View {
    
    // MARK: Properties

    @ObservedObject public var viewModel: PlayViewModel

    // MARK: Views
    
    init(viewModel: PlayViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            gameView()
            overlayUI()
            
            // Conditionally show the game end screen
            if viewModel.showEndGameScreen {
                gameEndUI()
            }
        }
        .onAppear {
            viewModel.configureGameScreen(size: UIScreen.main.bounds.size)
            animateMenuButtonsIn()
        }
    }

    private func gameView() -> some View {
//        GeometryReader { geometry in
            let scene = viewModel.getGameScene()
            return SpriteView(scene: scene)
                .ignoresSafeArea()
//                .position(CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2))
//                .frame(width: geometry.size.width, height: geometry.size.height)
//        }
    }
    
    private func overlayUI() -> some View {
        ZStack {
            // Score and time displays positioned independently at the top.
            VStack {
                HStack {
                    scoreDisplay()
                        .padding(.leading)
                    Spacer()
                    timeDisplay()
                        .padding(.trailing)
                }
                Spacer()
            }
            
            // Game buttons positioned independently in the center.
            if viewModel.showMenuButtons {
                menuButtons()
                    .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
                    .offset(y: viewModel.menuOffset)
            }
        }
    }
    
    private func menuButtons() -> some View {
        let buttonHeight: CGFloat = 80
        let buttonWidth: CGFloat = 200
        let buttonStyle = ThreeDimensionalButtonStyle(
            topColor: Color(.slimelRedTop),
            undersideColor: Color(.slimelRed),
            fontSize: 24)

        return VStack(spacing: 30) {
            Button("Play") {
                animateMenuButtonsOut()
                viewModel.playButtonTapped()
            }
            .buttonStyle(buttonStyle)
            .frame(width: buttonWidth, height: buttonHeight)
            .scaleEffect(viewModel.menuButtonsScale)
            
            Button("Zen Mode") {}
                .buttonStyle(buttonStyle)
                .frame(width: buttonWidth, height: buttonHeight)
                .scaleEffect(viewModel.menuButtonsScale)
            
            Button("Shop") {}
                .buttonStyle(buttonStyle)
                .frame(width: buttonWidth, height: buttonHeight)
                .scaleEffect(viewModel.menuButtonsScale)
        }
    }
    
    private func scoreDisplay() -> some View {
        Text("Score: \(viewModel.score)")
            .font(.custom(Fonts.Nunito.black.rawValue, size: viewModel.hudFontSize))
            .fontWeight(.bold)
            .fontDesign(.monospaced)
            .frame(minWidth: 50)
            .foregroundColor(.white)
            .shadow(radius: 6)
    }

    private func timeDisplay() -> some View {
        Text("\(viewModel.remainingTime)")
            .font(.custom(Fonts.Nunito.black.rawValue, size: viewModel.hudFontSize))
            .fontWeight(.bold)
            .fontDesign(.monospaced)
            .frame(minWidth: 50)
            .foregroundColor(.white)
            .shadow(radius: 6)

    }
    
    public func gameEndUI() -> some View {
        GameEndPopup(isShowing: $viewModel.showEndGameScreen, score: 123, playAgainAction: {
//            viewModel.restartGame()
            viewModel.showEndGameScreen = false
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
    }

    // MARK: Animations

    private func animateMenuButtonsIn() {
        withAnimation(.easeIn(duration: 0.25)) {
            viewModel.menuButtonsScale = 1.2
        }
        withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.5).delay(0.2)) {
            viewModel.menuButtonsScale = 1.0
        }
    }
    
    private func animateMenuButtonsOut() {
        withAnimation(.easeOut(duration: 0.3)) {
            viewModel.menuButtonsScale = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.showMenuButtons = false
        }
    }
}

// MARK: Preview
struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = PlayViewModel(gameManager: GameManagerFactory.make())
        PlayView(viewModel: vm)
    }
}
