//
//  TodoDetailsPresenter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import Foundation

class TodoDetailsPresenter: TodoDetailsPresenterProtocol {
    weak var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
}
