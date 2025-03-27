//
//  AddTodoInteractor.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import Foundation

class AddTodoInteractor: AddTodoInteractorProtocol {
    weak var presenter: AddTodoPresenterProtocol?
    
    func save(todo: Todo) {
        // save
        
        NotificationCenter.default.post(name: NSNotification.Name("TodoAdded"), object: nil, userInfo: ["todo": todo])
            
        presenter?.didSaveTodo()
    }
}
