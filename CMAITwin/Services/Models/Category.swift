import Foundation

enum Category: String, Codable, CaseIterable {
    case career = "Career"
    case emotions = "Emotions"
    case productivity = "Productivity"
    case other = "Other"

    var emoji: String {
        switch self {
        case .career:
            return "💼"
        case .emotions:
            return "😊"
        case .productivity:
            return "📈"
        case .other:
            return "🤔"
        }
    }
}