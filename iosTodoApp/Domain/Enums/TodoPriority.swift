import Foundation

struct TodoPriorityOption: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var colorHex: String

    static let defaults: [TodoPriorityOption] = [
        .init(id: "high", name: "High", colorHex: "#EF4444"),
        .init(id: "medium", name: "Medium", colorHex: "#F59E0B"),
        .init(id: "low", name: "Low", colorHex: "#10B981")
    ]

    static let defaultID = "medium"
}
