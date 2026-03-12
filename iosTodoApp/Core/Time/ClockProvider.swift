import Foundation

protocol ClockProvider {
    func now() -> Date
}

struct SystemClockProvider: ClockProvider {
    func now() -> Date { Date() }
}
