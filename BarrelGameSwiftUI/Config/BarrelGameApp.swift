//
//  BarrelGameSwiftUIApp.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import SwiftUI

@main
struct BarrelGameApp: App {
    var body: some Scene {
        WindowGroup {
            let vm = PlayViewModel(gameManager: GameManagerFactory.make())
            PlayView(viewModel: vm)
        }
    }
}
