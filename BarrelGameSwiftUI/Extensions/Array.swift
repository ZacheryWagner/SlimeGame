//
//  Array.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/8/24.
//

import Foundation

extension Array where Element: Equatable {
    /// Checks if all the elements in the array are the same.
    ///
    /// - Returns: `true` if all elements are the same or the array is empty, `false` otherwise.
    func allElementsEqual() -> Bool {
        guard let firstElement = self.first else {
            // The array is empty, so technically all elements (none) are the same.
            return true
        }
        return self.allSatisfy { $0 == firstElement }
    }
}
