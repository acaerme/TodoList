//
//  ViewController.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 25/03/2025.
//

import UIKit

class ViewController: UIViewController {
    
    private let networkManager = NetworkManager(url: "https://dummyjson.com/todos")
    
    var response: NetworkResponse?
    
    var todos: [ToDoNetworkObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        Task {
            response = try? await networkManager.fetchData()
            
            for todo in response?.todos ?? [] {
                print(todo.todo)
            }
        }
    }
}

