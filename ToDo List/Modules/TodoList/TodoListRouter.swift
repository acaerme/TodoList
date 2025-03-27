//
//  TodoListRouter.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

import UIKit

class TodoListRouter: TodoListRouterProtocol {
    
    // MARK: - Properties
    
    weak var viewController: TodoListViewController?
    
    // MARK: - Protocol Methods
    
    static func createModule() -> TodoListViewController {
        let view = TodoListViewController()
        let interactor = TodoListInteractor(networkManager: DependencyContainer.shared.container.resolve(NetworkManagerProtocol.self)!) // later is ! safe?
        let presenter = TodoListPresenter()
        let router = TodoListRouter()
        
        view.presenter = presenter
        
        interactor.presenter = presenter
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        router.viewController = view
        
        return view
    }
    
    func showDetails(for todo: Todo) {
        //        let detailsViewController = TodoDetailsViewController(todo: todo)
        //        viewController?.navigationController?.pushViewController(detailsViewController, animated: true)
    }
}
