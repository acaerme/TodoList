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
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        interactor?.fetchTodos()
    }
    
    // MARK: - Protocol Methods
    
    func interactorDidFetchTodos(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            view?.update(with: todos)
        case .failure(let error):
            print("Error fetching todos: \(error)") // later
        }
    }
    
    func didSelectTodo(todo: Todo) {
        router?.showDetails(for: todo)
    }
}
