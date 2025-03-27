//
//  TodoDetailsRouter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import UIKit

class TodoDetailsRouter: TodoDetailsRouterProtocol {
    
    weak var viewController: TodoDetailsViewController?
    
    static func createModule(with todo: Todo) -> TodoDetailsViewController {
        let view = TodoDetailsViewController(todo: todo)
        let interactor = TodoDetailsInteractor()
        let presenter = TodoDetailsPresenter()
        let router = TodoDetailsRouter()
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.viewController = view
        
        return view
    }
}
