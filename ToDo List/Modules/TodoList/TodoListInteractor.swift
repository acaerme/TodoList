import Foundation

// MARK: - TodoListInteractor

final class TodoListInteractor: TodoListInteractorProtocol {
    
    // MARK: - Properties
    
    private let networkManager: NetworkManagerProtocol
    private let coreDataManager: CoreDataManagerProtocol
    private var allTodos: [Todo] = []
    private var currentSearchText: String = ""
    weak var presenter: TodoListPresenterProtocol?
    
    // MARK: - Initialization
    
    init(networkManager: NetworkManagerProtocol, coreDataManager: CoreDataManagerProtocol) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods - Reflection
    
    private func reflectAddedTodo(newTodo: Todo) {
        allTodos.insert(newTodo, at: 0)
        presenter?.updateTodosList(with: .success(allTodos))
    }
    
    private func reflectUpdatedTodo(updatedTodo: Todo) {
        guard let index = allTodos.firstIndex(where: { $0.id == updatedTodo.id }) else { return }
        
        let oldTodo = allTodos[index]
        
        if oldTodo.completed != updatedTodo.completed {
            allTodos.remove(at: index)
            allTodos.insert(updatedTodo, at: index)
        } else {
            allTodos.remove(at: index)
            allTodos.insert(updatedTodo, at: 0)
        }
        
        filterTodos(with: currentSearchText) { filteredTodos in
            self.presenter?.updateTodosList(with: .success(filteredTodos))
        }
    }
    
    private func reflectDeletedTodo(id: UUID) {
        guard let index = allTodos.firstIndex(where: { $0.id == id }) else { return }
        allTodos.remove(at: index)
        presenter?.updateTodosList(with: .success(allTodos))
    }
    
    private func reflectAllTodosDeleted() {
        allTodos.removeAll()
        presenter?.updateTodosList(with: .success(self.allTodos))
    }
    
    // MARK: - Public Methods - Data Fetching
    
    func fetchTodos() {
        if isFirstLaunch() {
            fetchFromAPIAndSaveToCoreData()
        } else {
            fetchFromCoreData()
        }
    }
    
    private func fetchFromAPIAndSaveToCoreData() {
        networkManager.fetchTodos { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let networkResponse):
                UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                UserDefaults.standard.synchronize()
                let todos = networkResponse.todos.map {
                    Todo(id: UUID(),
                         title: $0.todo,
                         description: "Description",
                         date: Date(),
                         completed: $0.completed)
                }
                
                self.coreDataManager.saveTodos(todos: todos) { error in
                    if let error = error {
                        self.presenter?.updateTodosList(with: .failure(error))
                    } else {
                        self.allTodos = todos.reversed()
                        self.presenter?.updateTodosList(with: .success(self.allTodos))
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presenter?.updateTodosList(with: .failure(error))
                }
            }
        }
    }
    
    private func fetchFromCoreData() {
        coreDataManager.getAllTodos { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let todos):
                self.allTodos = todos
                self.presenter?.updateTodosList(with: .success(todos))
            case .failure(let error):
                self.presenter?.updateTodosList(with: .failure(error))
            }
        }
    }
    
    // MARK: - Public Methods - Data Manipulation
    
    func filterTodos(with searchText: String, completion: @escaping (([Todo]) -> Void)) {
        currentSearchText = searchText
        
        guard !searchText.isEmpty else {
            completion(allTodos)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let filteredTodos = self.allTodos.filter {
                ($0.title ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.description ?? "").lowercased().contains(searchText.lowercased())
            }
            
            DispatchQueue.main.async {
                completion(filteredTodos)
            }
        }
    }
    
    func updateTodo(updatedTodo: Todo) {
        coreDataManager.updateTodo(todo: updatedTodo) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentStandardErrorAlert()
                return
            }
            
            self?.reflectUpdatedTodo(updatedTodo: updatedTodo)
        }
    }
    
    func delete(id: UUID) {
        coreDataManager.deleteTodo(id: id) { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentStandardErrorAlert()
                return
            }
            
            self?.reflectDeletedTodo(id: id)
        }
    }
    
    func deleteAllTodos() {
        coreDataManager.deleteAllTodos { [weak self] error in
            guard error == nil else {
                self?.presenter?.presentStandardErrorAlert()
                return
            }
            
            self?.reflectAllTodosDeleted()
        }
    }
    
    // MARK: - Private Methods - Helpers
    
    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
    }
    
    // MARK: - Private Methods - Notification Handling
    
    private func setupNotifications() {
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
                                             selector: #selector(somethingWentWrong(_:)),
                                             name: NSNotification.Name("ErrorOccurredWithCoreData"),
                                             object: nil)
    }
    
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
    
    @objc private func somethingWentWrong(_ notification: Notification) {
        presenter?.presentStandardErrorAlert()
    }
}
