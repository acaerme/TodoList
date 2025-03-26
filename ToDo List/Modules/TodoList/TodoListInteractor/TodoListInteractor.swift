//
//  TodoListInteractor.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// TodoListInteractor.swift

import Foundation

class TodoListInteractor: TodoListInteractorProtocol {
    private let networkManager: NetworkManagerProtocol
    weak var presenter: TodoListPresenterProtocol?
 
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }

    func fetchTodos() {
        // Implementation will go here to fetch todos
    }
}
