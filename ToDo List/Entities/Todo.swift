import Foundation

struct Todo {
    let id: UUID
    let title: String?
    let description: String?
    let date: Date
    var completed: Bool
}

extension Todo: Equatable {
    public static func == (lhs: Todo, rhs: Todo) -> Bool {
        return lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.completed == rhs.completed
    }
}
