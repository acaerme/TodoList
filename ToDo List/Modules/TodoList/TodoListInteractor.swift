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
                                               selector: #selector(todoAdded(_:)),
                                               name: NSNotification.Name("TodoAdded"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoEdited(_:)),
                                               name: NSNotification.Name("TodoEdited"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoDeleted(_:)),
                                               name: NSNotification.Name("TodoDeleted"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(allTodosDeleted(_:)),
                                               name: NSNotification.Name("AllTodosDeleted"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Updates
    
    private func reflectAddedTodo(newTodo: Todo) {
        allTodos.insert(newTodo, at: 0)
        presenter?.updateTodosList(with: .success(allTodos))
    }
    
    private func reflectUpdatedTodo(updatedTodo: Todo) {
        if let index = allTodos.firstIndex(where: { $0.id == updatedTodo.id }) {
            allTodos[index] = updatedTodo
            presenter?.updateTodosList(with: .success(allTodos))
        }
    }
    
    private func reflectDeletedTodo(id: UUID) {
        if let index = allTodos.firstIndex(where: { $0.id == id }) {
            allTodos.remove(at: index)
            presenter?.updateTodosList(with: .success(allTodos))
        }
    }
    
    private func reflectAllTodosDeleted() {
        allTodos.removeAll()
        presenter?.updateTodosList(with: .success(allTodos))
    }
    
    // MARK: - Data Fetching
    
    func fetchTodos() {
        if isFirstLaunch() {
            fetchFromAPIAndSaveToCoreData()
        } else {
            fetchFromCoreData()
        }
    }
    
    func fetchFromAPIAndSaveToCoreData() {
        Task {
            do {
                let networkResponse = try await networkManager.fetchTodos()
                let todos = networkResponse.todos.map {
                    Todo(id: UUID(),
                         title: $0.todo,
                         description: "Description",
                         date: Date(),
                         completed: $0.completed)
                }
                
                CoreDataManager.shared.saveTodos(todos: todos)
                
                allTodos = todos.reversed()
                presenter?.updateTodosList(with: .success(allTodos))
                
                UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                UserDefaults.standard.synchronize()
            } catch {
                presenter?.updateTodosList(with: .failure(error))
            }
        }
    }
    
    func fetchFromCoreData() {
        CoreDataManager.shared.getAllTodos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.allTodos = todos
                self?.presenter?.updateTodosList(with: .success(todos))
            case .failure(let error):
                self?.presenter?.updateTodosList(with: .failure(error))
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
    
    func updateTodo(updatedTodo: Todo) {
        CoreDataManager.shared.updateTodo(updatedTodo: updatedTodo)
    }
    
    func delete(id: UUID) {
        CoreDataManager.shared.deleteTodo(id: id)
    }
    
    func deleteAllTodos() {
        CoreDataManager.shared.deleteAllTodos()
    }
    
    // MARK: - Private Methods
    
    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
    }
    
    // MARK: - Notification Handlers
    
    @objc private func todoAdded(_ notification: Notification) {
        guard let newTodo = notification.userInfo?["todo"] as? Todo else { return }
        reflectAddedTodo(newTodo: newTodo)
    }
    
    @objc private func todoEdited(_ notification: Notification) {
        guard let updatedTodo = notification.userInfo?["todo"] as? Todo else { return }
        reflectUpdatedTodo(updatedTodo: updatedTodo)
    }
    
    @objc private func todoDeleted(_ notification: Notification) {
        guard let todoId = notification.userInfo?["todoId"] as? UUID else { return }
        reflectDeletedTodo(id: todoId)
    }
    
    @objc private func allTodosDeleted(_ notification: Notification) {
        reflectAllTodosDeleted()
    }
}
