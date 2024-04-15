//
//  ContentView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import Combine
import SwiftUI
import SpriteKit

struct PlayView: View {
    
    // MARK: Properties
    
    private let offset: CGFloat = -35
    
    private var cancellables = Set<AnyCancellable>()

    @ObservedObject public var viewModel: PlayViewModel

    // MARK: Views
    
    init(viewModel: PlayViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            gameView()
            if viewModel.isButtonsHidden {
                mainUI()
            }
        }
        .onAppear {
            viewModel.configureGameScreen(size: UIScreen.main.bounds.size)
            animateButtons()
        }
    }

    private func gameView() -> some View {
        GeometryReader { geometry in
            let scene = viewModel.getGameScene()
            SpriteView(scene: scene)
                .ignoresSafeArea()
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
                viewModel.playButtonTapped()
            }
            .buttonStyle(buttonStyle)
            .frame(width: buttonWidth, height: buttonHeight)
            .scaleEffect(viewModel.scale)
            
            Button("Zen Mode") {}
                .buttonStyle(buttonStyle)
                .frame(width: buttonWidth, height: buttonHeight)
                .scaleEffect(viewModel.scale)
            
            Button("Shop") {}
                .buttonStyle(buttonStyle)
                .frame(width: buttonWidth, height: buttonHeight)
                .scaleEffect(viewModel.scale)
        }
        .offset(y: offset)
    }

    // MARK: Animations

    private func animateButtons() {
        withAnimation(.easeIn(duration: 0.25)) {
            viewModel.scale = 1.2
        }
        withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.5).delay(0.2)) {
            viewModel.scale = 1.0
        }
    }
    
    private func animateButtonsOut() {
        withAnimation(.easeOut(duration: 0.3)) {
            viewModel.scale = 0.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.isButtonsHidden = false
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
