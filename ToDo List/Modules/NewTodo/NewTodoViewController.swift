//
//  NewTodoViewController.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import UIKit

// later может стоит переименовать NewTodo на AddTodo

class NewTodoViewController: UIViewController, NewTodoViewProtocol {
    
    var presenter: NewTodoPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
    }
}
