import Foundation
import OSLog

protocol AppLogger {
    func info(_ message: String)
    func error(_ message: String)
}

struct OSAppLogger: AppLogger {
    private let logger = Logger(subsystem: "com.benz.iosTodoApp", category: "app")

    func info(_ message: String) {
        logger.info("\\(message, privacy: .public)")
    }

    func error(_ message: String) {
        logger.error("\\(message, privacy: .public)")
    }
}
