//
//  AddTodoRouter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 27/03/2025.
//

import UIKit

class AddTodoRouter: AddTodoRouterProtocol {
    weak var viewController: AddTodoViewController?
    
    static func createModule() -> AddTodoViewController {
        let view = AddTodoViewController()
        let presenter = AddTodoPresenter()
        let interactor = AddTodoInteractor()
        let router = AddTodoRouter()
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.viewController = view
        
        return view
    }
    
    func dismissVC() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
