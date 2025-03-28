import Foundation

final class TodoListInteractor: TodoListInteractorProtocol {
    
    // MARK: - Properties
    
    private let networkManager: NetworkManagerProtocol
    private var allTodos: [Todo] = []
    weak var presenter: TodoListPresenterProtocol?
    
    // MARK: - Initialization
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - Data Methods
    
    func fetchTodos() {
        Task {
            do {
                let networkResponse = try await networkManager.fetchTodos()
                allTodos = networkResponse.todos.map {
                    Todo(id: UUID(),
                         title: $0.todo,
                         description: "Description",
                         date: Date(),
                         completed: $0.completed)
                }
                presenter?.updateTodosList(with: .success(allTodos))
            } catch {
                presenter?.updateTodosList(with: .failure(error))
            }
        }
    }
    
    func filterTodos(with searchText: String) {
        if searchText.isEmpty {
            presenter?.updateTodosList(with: .success(allTodos))
        } else {
            
            let filteredTodos = allTodos.filter { ($0.title ?? "").lowercased().contains(searchText.lowercased()) }
            presenter?.updateTodosList(with: .success(filteredTodos))
        }
    }
    
    func toggleTodoCompletion(for updatedTodo: Todo) {
        if let index = allTodos.firstIndex(where: { $0.id == updatedTodo.id }) {
            allTodos[index].completed.toggle()
        }
        presenter?.updateTodosList(with: .success(allTodos))
    }
    
    func addOrUpdate(todo: Todo) {
            if let index = allTodos.firstIndex(where: { $0.id == todo.id }) {
                allTodos[index] = todo
            } else {
                allTodos.insert(todo, at: 0)
            }
            presenter?.updateTodosList(with: .success(allTodos))
    }
    
    func delete(id: UUID) {
        if let index = allTodos.firstIndex(where: { $0.id == id }) {
            allTodos.remove(at: index)
        }

        presenter?.updateTodosList(with: .success(allTodos))
    }
}
