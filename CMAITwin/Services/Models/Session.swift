import Foundation

struct Session: Identifiable, Codable {
    let id: Int
    let date: Date
    let title: String
    let category: Category
    let summary: String
}