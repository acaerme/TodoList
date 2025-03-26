//
//  DependencyContainer.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

// DependencyContainer.swift

import Swinject

class DependencyContainer {
    static let shared = DependencyContainer()
    
    let container: Container
    
    private init() {
        container = Container()
        
        // Register NetworkManager
        container.register(NetworkManagerProtocol.self) { _ in
            NetworkManager(url: "https://dummyjson.com/todos")
        }
        
        // Register Interactor
        container.register(TodoListInteractorProtocol.self) { r in
            guard let networkManager = r.resolve(NetworkManagerProtocol.self) else {
                fatalError("Failed to resolve NetworkManagerProtocol")
            }
            return TodoListInteractor(networkManager: networkManager)
        }
        
        // Register Presenter
        container.register(TodoListPresenterProtocol.self) { _ in
            TodoListPresenter()
        }
        
        // Register Router
        container.register(TodoListRouterProtocol.self) { _ in
            TodoListRouter()
        }
        
        // Register View
        container.register(TodoListViewController.self) { r in
            guard let presenter = r.resolve(TodoListPresenterProtocol.self),
                  let interactor = r.resolve(TodoListInteractorProtocol.self),
                  let router = r.resolve(TodoListRouterProtocol.self) else {
                fatalError("Failed to resolve dependencies for TodoListViewController")
            }
            
            let view = TodoListViewController()
            
            view.presenter = presenter
            interactor.presenter = presenter
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            
            router.viewController = view
            
            return view
        }
    }
}
