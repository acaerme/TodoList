//
//  NewTodoPresenter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import Foundation

class NewTodoPresenter: NewTodoPresenterProtocol {
    weak var view: NewTodoViewProtocol?
    var interactor: NewTodoInteractorProtocol?
    var router: NewTodoRouterProtocol?
}
