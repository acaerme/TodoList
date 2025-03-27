import UIKit

class TodoListRouter: TodoListRouterProtocol {
    
    // MARK: - Properties
    
    weak var viewController: TodoListViewController?
    
    // MARK: - TodoListRouterProtocol Methods
    
    static func createModule() -> TodoListViewController {
        let view = TodoListViewController()
        let interactor = TodoListInteractor(networkManager: DependencyContainer.shared.container.resolve(NetworkManagerProtocol.self)!)
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
        let detailsViewController = TodoDetailsRouter.createModule(with: todo)
        viewController?.navigationController?.pushViewController(detailsViewController, animated: true)
    }
    
    func presentNewTodoVC() {
        let addTodoViewController = AddTodoRouter.createModule()
        addTodoViewController.modalPresentationStyle = .fullScreen
        viewController?.present(addTodoViewController, animated: true)
    }
}
