//
//  AddTodoPresenter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import Foundation

class AddTodoPresenter: AddTodoPresenterProtocol {
    weak var view: AddTodoViewProtocol?
    var interactor: AddTodoInteractorProtocol?
    var router: AddTodoRouterProtocol?
    
    func cancelButtonTapped() {
        router?.dismissVC()
    }
    
    func saveButtonTapped(todo: Todo) {
        interactor?.save(todo: todo)
    }
    
    func didSaveTodo() {
        router?.dismissVC()
    }
}
