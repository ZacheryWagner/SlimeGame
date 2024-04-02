//
//  Logger.swift
//  BarrelGameSwiftUI
//
//  Created by Zachery Wagner on 4/1/24.
//

import Foundation

class Logger {
    static func info(_ message: String) {
        printLog(level: "INFO", message: message)
    }

    static func warning(_ message: String) {
        printLog(level: "WARNING", message: message)
    }

    static func error(_ message: String) {
        printLog(level: "ERROR", message: message)
    }

    // New function to log errors directly
    static func error(_ error: Error) {
        let errorMessage = error.localizedDescription
        printLog(level: "ERROR", message: errorMessage)
    }

    private static func printLog(level: String, message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        print("[\(timestamp)] [\(level)] \(message)")
    }
}
