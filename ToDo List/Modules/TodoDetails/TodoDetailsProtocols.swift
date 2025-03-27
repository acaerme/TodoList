//
//  ToDoListProtocols.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// TodoDetailsProtocols.swift

import Foundation

// View
protocol TodoDetailsViewProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
}

// Interactor
protocol TodoDetailsInteractorProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
}

// Presenter
protocol TodoDetailsPresenterProtocol: AnyObject {
    var view: TodoDetailsViewProtocol? { get set }
    var interactor: TodoDetailsInteractorProtocol? { get set }
    var router: TodoDetailsRouterProtocol? { get set }
}

// Router
protocol TodoDetailsRouterProtocol: AnyObject {
    var viewController: TodoDetailsViewController? { get set }
    
    static func createModule(with: Todo) -> TodoDetailsViewController
}
