import Foundation

struct NetworkResponse: Codable {
    let todos: [ToDoNetworkObject]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ToDoNetworkObject: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
