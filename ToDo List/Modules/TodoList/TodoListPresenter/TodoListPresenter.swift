//
//  TodoListPresenter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// TodoListPresenter.swift

import Foundation

class TodoListPresenter: TodoListPresenterProtocol {
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?
    
    func viewDidLoad() {
        interactor?.fetchTodos()
    }
    
    func interactorDidFetchTodos(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            view?.update(with: todos)
        case .failure(let error):
            print("Error fetching todos: \(error)") // later
        }
    }
}
