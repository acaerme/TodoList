//
//  AddTodoProtocols.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

// View
protocol AddTodoViewProtocol: AnyObject {
    var presenter: AddTodoPresenterProtocol? { get set }
}

// Interactor
protocol AddTodoInteractorProtocol: AnyObject {
    var presenter: AddTodoPresenterProtocol? { get set }
    
    func save(todo: Todo)
}

// Presenter
protocol AddTodoPresenterProtocol: AnyObject {
    var view: AddTodoViewProtocol? { get set }
    var interactor: AddTodoInteractorProtocol? { get set }
    var router: AddTodoRouterProtocol? { get set }
    
    func cancelButtonTapped()
    func saveButtonTapped(todo: Todo)
    func didSaveTodo()
}

// Router
protocol AddTodoRouterProtocol: AnyObject {
    var viewController: AddTodoViewController? { get set }
    
    static func createModule() -> AddTodoViewController
    func dismissVC()
}
