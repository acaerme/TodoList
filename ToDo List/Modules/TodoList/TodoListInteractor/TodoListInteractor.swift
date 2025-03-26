//
//  TodoListInteractor.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// TodoListInteractor.swift

import Foundation

class TodoListInteractor: TodoListInteractorProtocol {

    // MARK: - Properties

    private let networkManager: NetworkManagerProtocol
    weak var presenter: TodoListPresenterProtocol?
    
    // MARK: - Initialization

    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    // MARK: - Data Fetching

    func fetchTodos() {
        Task {
            do {
                let networkResponse = try await networkManager.fetchTodos()
                let todos = networkResponse.todos.map {
                    Todo(title: $0.todo,
                         description: "Description",
                         date: Date(),
                         completed: $0.completed)
                }
                presenter?.interactorDidFetchTodos(with: .success(todos))
            } catch {
                presenter?.interactorDidFetchTodos(with: .failure(error))
            }
        }
    }
}
