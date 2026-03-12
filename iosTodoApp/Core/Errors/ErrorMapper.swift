import Foundation

struct ErrorMapper {
    func userMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            return appError.errorDescription ?? "Something went wrong."
        }
        return "Something went wrong."
    }
}
