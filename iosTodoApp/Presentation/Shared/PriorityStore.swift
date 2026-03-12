import Foundation
import SwiftUI

@MainActor
final class PriorityStore: ObservableObject {
    @Published private(set) var priorities: [TodoPriorityOption] = []

    private let key = "settings.priorities"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    func load() {
        guard
            let data = defaults.data(forKey: key),
            let decoded = try? decoder.decode([TodoPriorityOption].self, from: data),
            !decoded.isEmpty
        else {
            priorities = TodoPriorityOption.defaults
            persist()
            return
        }
        priorities = decoded
    }

    func addPriority() {
        let id = "custom-\(UUID().uuidString.lowercased())"
        priorities.append(.init(id: id, name: "New Priority", colorHex: "#3B82F6"))
        persist()
    }

    func updateName(id: String, name: String) {
        guard let idx = priorities.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        priorities[idx].name = trimmed.isEmpty ? "Priority" : trimmed
        persist()
    }

    func updateColor(id: String, colorHex: String) {
        guard let idx = priorities.firstIndex(where: { $0.id == id }) else { return }
        priorities[idx].colorHex = colorHex
        persist()
    }

    func deletePriority(id: String) {
        guard priorities.count > 1 else { return }
        priorities.removeAll { $0.id == id }
        if priorities.isEmpty {
            priorities = [TodoPriorityOption.defaults[0]]
        }
        persist()
    }

    func option(for id: String) -> TodoPriorityOption? {
        priorities.first(where: { $0.id == id })
    }

    func firstAvailableID() -> String {
        priorities.first?.id ?? TodoPriorityOption.defaultID
    }

    private func persist() {
        if let data = try? encoder.encode(priorities) {
            defaults.set(data, forKey: key)
        }
    }
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let r, g, b: Double
        if cleaned.count == 6 {
            r = Double((value >> 16) & 0xFF) / 255
            g = Double((value >> 8) & 0xFF) / 255
            b = Double(value & 0xFF) / 255
        } else {
            r = 0.23
            g = 0.51
            b = 0.96
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }

    func toHex() -> String {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        #else
        return "#3B82F6"
        #endif
    }
}
