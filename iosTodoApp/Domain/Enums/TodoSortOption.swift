import Foundation

enum TodoSortOption: String, CaseIterable, Identifiable {
    case createdNewest
    case createdOldest
    case dueSoonest
    case priorityHighFirst

    var id: String { rawValue }

    var title: String {
        switch self {
        case .createdNewest: return "Newest"
        case .createdOldest: return "Oldest"
        case .dueSoonest: return "Due Soonest"
        case .priorityHighFirst: return "Priority"
        }
    }
}
