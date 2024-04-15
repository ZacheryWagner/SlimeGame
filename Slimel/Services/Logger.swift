//
//  Logger.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation
class Logger {
    /// Object type represented as a Stringto tag logs
    private let source: String
    
    /// Initializes an instance of `Logger`
    /// - Parameter source: Object type to tag logs with
    init(source: Any) {
        self.source = String(describing: source.self)
    }

    func info(_ message: String) {
        printLog(level: "INFO", message: message)
    }

    func warning(_ message: String) {
        printLog(level: "WARNING", message: message)
    }

    func error(_ message: String) {
        printLog(level: "ERROR", message: message)
    }

    func error(_ error: Error) {
        let errorMessage = error.localizedDescription
        printLog(level: "ERROR", message: errorMessage)
    }

    private func printLog(level: String, message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        print("[\(timestamp)][\(level)] [\(source)] \(message)")
    }
}
