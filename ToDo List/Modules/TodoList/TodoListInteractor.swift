// TodoListInteractor.swift

import Foundation

final class TodoListInteractor: TodoListInteractorProtocol {
    
    private let networkManager: NetworkManagerProtocol
    private let coreDataManager: CoreDataManager
    private var allTodos: [Todo] = []
    weak var presenter: TodoListPresenterProtocol?
    
    init(networkManager: NetworkManagerProtocol, coreDataManager: CoreDataManager) {
        self.networkManager = networkManager
        self.coreDataManager = coreDataManager
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func reflectAddedTodo(newTodo: Todo) {
        allTodos.insert(newTodo, at: 0)
        presenter?.updateTodosList(with: .success(allTodos))
    }
    
    private func reflectUpdatedTodo(updatedTodo: Todo) {
        if let index = allTodos.firstIndex(where: { $0.id == updatedTodo.id }) {
            let oldTodo = allTodos[index]
            
            if oldTodo.completed != updatedTodo.completed {
                allTodos.remove(at: index)
                allTodos.insert(updatedTodo, at: index)
            } else {
                allTodos.remove(at: index)
                allTodos.insert(updatedTodo, at: 0)
            }
            //later
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
        print("calleddddd")
        allTodos.removeAll()
        presenter?.updateTodosList(with: .success(self.allTodos))
    }
    
    func fetchTodos() {
        if isFirstLaunch() {
            fetchFromAPIAndSaveToCoreData()
        } else {
            fetchFromCoreData()
        }
    }
    
    func fetchFromAPIAndSaveToCoreData() {
            networkManager.fetchTodos { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let networkResponse):
                    let todos = networkResponse.todos.map {
                        Todo(id: UUID(),
                             title: $0.todo,
                             description: "Description",
                             date: Date(),
                             completed: $0.completed)
                    }
                    
                    self.coreDataManager.saveTodos(todos: todos) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self.presenter?.updateTodosList(with: .failure(error))
                            } else {
                                self.allTodos = todos.reversed()
                                self.presenter?.updateTodosList(with: .success(self.allTodos))
                                UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                                UserDefaults.standard.synchronize()
                            }
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.presenter?.updateTodosList(with: .failure(error))
                    }
                }
            }
        }
    
    func fetchFromCoreData() {
            coreDataManager.getAllTodos { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let todos):
                        self.allTodos = todos
                        self.presenter?.updateTodosList(with: .success(todos))
                    case .failure(let error):
                        self.presenter?.updateTodosList(with: .failure(error))
                    }
                }
            }
        }
    
    func filterTodos(with searchText: String, completion: @escaping (([Todo]) -> Void)) {
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
        print("udalyau")
        coreDataManager.deleteAllTodos { [weak self] error in
            print(1)
            guard error == nil else {
                print("oshibka")
                self?.presenter?.presentStandardErrorAlert()
                return
            }
            print(2)
            print("tut")
            print(self)
            self?.reflectAllTodosDeleted()
        }
    }
    
    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
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
