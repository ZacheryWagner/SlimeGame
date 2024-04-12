//
//  NeumorphicButtonStyle.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/12/24.
//

import Foundation
import SwiftUI

struct NeumorphicButtonStyle: ButtonStyle {
    var baseColor: Color = Color(UIColor.systemGray6) // Close to background color for blending
    var cornerRadius: CGFloat = 10

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(20)
            .background(GeometryReader { geometry in
                ZStack {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(baseColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 2, y: 2)
                            .shadow(color: Color.white.opacity(0.7), radius: 3, x: -2, y: -2)
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(baseColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 5, y: 5)
                            .shadow(color: Color.white.opacity(0.7), radius: 3, x: -5, y: -5)
                    }
                }
            })
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NeumorphicButtonPreview: PreviewProvider {
    static var previews: some View {
        Button("Play") {}
            .foregroundColor(.black)
            .buttonStyle(NeumorphicButtonStyle())
            .padding()
            .background(Color(UIColor.systemGray6)) // To blend in for a neumorphic effect
    }
}

