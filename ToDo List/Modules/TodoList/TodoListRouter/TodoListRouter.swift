//
//  TodoListRouter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

import UIKit

class TodoListRouter: TodoListRouterProtocol {

    // MARK: - Properties

    weak var viewController: TodoListViewController?

    // MARK: - Static Methods

    static func createModule() -> TodoListViewController {
        let view = DependencyContainer.shared.container.resolve(TodoListViewController.self)!
        return view
    }
}
