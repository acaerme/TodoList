import Foundation

// MARK: - TodoListInteractor

final class TodoListInteractor: TodoListInteractorProtocol {

    // MARK: - Properties

    private let networkManager: NetworkManagerProtocol
    private var allTodos: [Todo] = []
    weak var presenter: TodoListPresenterProtocol?

    // MARK: - Initializers
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoAddedorUpdated(_:)),
                                               name: NSNotification.Name("TodoAddedOrUpdated"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoDeleted(_:)),
                                               name: NSNotification.Name("TodoDeleted"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Data Fetching

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

    // MARK: - Data Filtering

    func filterTodos(with searchText: String) {
        if searchText.isEmpty {
            presenter?.updateTodosList(with: .success(allTodos))
        } else {
            let filteredTodos = allTodos.filter { ($0.title ?? "").lowercased().contains(searchText.lowercased()) }
            presenter?.updateTodosList(with: .success(filteredTodos))
        }
    }

    // MARK: - Data Manipulation

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
    
    // MARK: - Notification Handlers

    @objc private func todoAddedorUpdated(_ notification: Notification) {
        guard let newTodo = notification.userInfo?["todo"] as? Todo else { return }
        addOrUpdate(todo: newTodo)
    }

    @objc private func todoDeleted(_ notification: Notification) {
        guard let todoId = notification.userInfo?["todoId"] as? UUID else { return }
        delete(id: todoId)
    }
}
