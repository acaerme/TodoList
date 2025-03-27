//
//  TodoDetailsViewController.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//
// later make classes final

import UIKit

class TodoDetailsViewController: UIViewController {
    
    private let todo: Todo

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .purple
    }
    
    init(todo: Todo) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
