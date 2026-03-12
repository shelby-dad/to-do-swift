import Foundation

enum AppError: LocalizedError, Equatable {
    case validation(String)
    case notFound
    case persistence(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .validation(let message):
            return message
        case .notFound:
            return "The requested item could not be found."
        case .persistence:
            return "A local storage error occurred."
        case .unknown:
            return "Something went wrong."
        }
    }
}
