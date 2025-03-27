//
//  NewTodoRouter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import UIKit

class NewTodoRouter: NewTodoRouterProtocol {
    weak var viewController: NewTodoViewController?
    
    static func createModule() -> NewTodoViewController {
        let view = NewTodoViewController()
        let presenter = NewTodoPresenter()
        let interactor = NewTodoInteractor()
        let router = NewTodoRouter()
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.viewController = view
        
        return view
    }
}
