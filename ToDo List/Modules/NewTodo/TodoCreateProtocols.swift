//
//  NewTodoProtocols.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

// View
protocol NewTodoViewProtocol: AnyObject {
    var presenter: NewTodoPresenterProtocol? { get set }
}

// Interactor
protocol NewTodoInteractorProtocol: AnyObject {
    var presenter: NewTodoPresenterProtocol? { get set }
}

// Presenter
protocol NewTodoPresenterProtocol: AnyObject {
    var view: NewTodoViewProtocol? { get set }
    var interactor: NewTodoInteractorProtocol? { get set }
    var router: NewTodoRouterProtocol? { get set }
}

// Router
protocol NewTodoRouterProtocol: AnyObject {
    var viewController: NewTodoViewController? { get set }
    
    static func createModule() -> NewTodoViewController
}
