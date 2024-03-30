//
//  ContentView.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 3/25/24.
//

import SwiftUI

struct ContentView: View {
    var board = Board()
    
    init() {
        board.generateGameReadyBoard()
        board.prettyPrintMatrix()
        
        board.moveLeft(row: 0)
        board.prettyPrintMatrix()
        board.moveRight(row: 0)
        board.prettyPrintMatrix()

        board.moveLeft(row: 3)
        board.prettyPrintMatrix()
        board.moveRight(row: 3)
        board.prettyPrintMatrix()
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("idk")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
