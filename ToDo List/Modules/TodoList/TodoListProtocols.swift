//
//  ToDoListProtocols.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// TodoListProtocols.swift

import Foundation

// View
protocol TodoListViewProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    
    func update(with todos: [Todo])
}

// Interactor
protocol TodoListInteractorProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    
    func fetchTodos()
}

// Presenter
protocol TodoListPresenterProtocol: AnyObject {
    var view: TodoListViewProtocol? { get set }
    var interactor: TodoListInteractorProtocol? { get set }
    var router: TodoListRouterProtocol? { get set }

    func viewDidLoad()
    func interactorDidFetchTodos(with result: Result<[Todo], Error>)
}

// Router
protocol TodoListRouterProtocol: AnyObject {
    static func createModule() -> TodoListViewController
    // func presentTodoDetail(from view: TodoListViewProtocol, for todo: Todo) // Example
}
