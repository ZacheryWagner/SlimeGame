//
//  GameOverView.swift
//  Slimel
//
//  Created by Zachery Wagner on 4/15/24.
//

import Foundation
import SwiftUI

struct GameEndPopup: View {
    @Binding var isShowing: Bool
    let score: Int
    let playAgainAction: () -> Void
    
    var body: some View {
        if isShowing {
            ZStack {
                // Background shadow
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.isShowing = false
                    }

                // Popup content
                VStack(spacing: 20) {
                    Text("Game Over!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your Score: \(score)")
                        .font(.title3)
                    
                    Button(action: {
                        self.playAgainAction()
                        self.isShowing = false
                    }) {
                        Text("Play Again")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 10)
                .frame(width: 300, height: 200)
            }
            .animation(.easeInOut, value: isShowing)
        }
    }
}

class GameEndPopupViewModel: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var score: Int = 0

    var playAgainAction: () -> Void

    init(playAgainAction: @escaping () -> Void) {
        self.playAgainAction = playAgainAction
    }

    func show(score: Int) {
        self.score = score
        isShowing = true
    }

    func hide() {
        isShowing = false
    }

    func playAgain() {
        playAgainAction()
        hide()
    }
}

// MARK: Preview
struct GameEndPopup_Previews: PreviewProvider {
    static var previews: some View {
        @State var showGameEndUI = true
        GameEndPopup(isShowing: $showGameEndUI, score: 123, playAgainAction: {
            showGameEndUI = false
        })
    }
}
