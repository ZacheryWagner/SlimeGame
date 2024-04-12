//
//  ThreeDimensionalButtonStyle.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/12/24.
//

import Foundation
import SwiftUI

struct ThreeDimensionalButtonStyle: ButtonStyle {
    var topColor: Color
    var undersideColor: Color
    var fontSize: CGFloat
    var pressedOffset: CGFloat = 4
    var normalOffset: CGFloat = 8
    var cornerRadius: CGFloat = 6
    var shadowRadius: CGFloat = 6
    var shadowOffsetY: CGFloat = 4

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            let currentOffset = configuration.isPressed ? pressedOffset : 0

            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(undersideColor)
                .offset(y: normalOffset)

            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(topColor)
                .offset(y: currentOffset)

            configuration.label
                .font(.custom("Nunito-Black", size: fontSize))
                .foregroundColor(.white)
                .shadow(color: .gray.opacity(0.5), radius: 1, x: 1, y: 1)
                .offset(y: currentOffset)
        }
        .compositingGroup()
        .shadow(radius: shadowRadius, y: shadowOffsetY)
    }
}

struct ThreeDimensionalButtonPreview: PreviewProvider {
    static var previews: some View {
        Button("Play") {}
            .frame(width: 200, height: 60)
            .buttonStyle(ThreeDimensionalButtonStyle(topColor: .gray, undersideColor: .black, fontSize: 24))
    }
}
