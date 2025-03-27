//
//  TodoListPresenter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

import Foundation

class TodoListPresenter: TodoListPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?
    private var todos: [Todo] = []
    
    // MARK: - Lifecycle
    
    init() {
        // Subscribe to the notification of a new todo.
        NotificationCenter.default.addObserver(self, selector: #selector(todoAdded(_:)), name: NSNotification.Name("TodoAdded"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidLoad() {
        interactor?.fetchTodos()
    }
    
    // MARK: - Protocol Methods
    
    func interactorDidFetchTodos(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            self.todos = todos
            view?.update(with: todos)
        case .failure(let error):
            print("Error fetching todos: \(error)") // later
        }
    }
    
    func didSelectTodo(todo: Todo) {
        router?.showDetails(for: todo)
    }
    
    func newTodoButtonTapped() {
        router?.presentNewTodoVC()
    }
    
    @objc private func todoAdded(_ notification: Notification) {
        if let todo = notification.userInfo?["todo"] as? Todo {
            todos.insert(todo, at: 0)
            view?.update(with: todos)
        }
    }
}
