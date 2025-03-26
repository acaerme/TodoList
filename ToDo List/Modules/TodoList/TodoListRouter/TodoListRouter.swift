//
//  TodoListRouter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// TodoListRouter.swift

import UIKit

class TodoListRouter: TodoListRouterProtocol {
    weak var viewController: TodoListViewController?
    
    static func createModule() -> TodoListViewController {
        let view = DependencyContainer.shared.container.resolve(TodoListViewController.self)!
        return view
    }
}
