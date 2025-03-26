//
//  TodoListViewController.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

import UIKit

class TodoListViewController: UIViewController, TodoListViewProtocol {

    // MARK: - Properties

    var presenter: TodoListPresenterProtocol?

    // MARK: - Protocol Methods

    func update(with todos: [Todo]) {
        for todo in todos {
            print(todo.title)
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .separator

        presenter?.viewDidLoad()
    }
}
