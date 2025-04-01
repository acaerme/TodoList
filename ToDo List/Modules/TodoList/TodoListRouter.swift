import UIKit

// MARK: - TodoListRouter

final class TodoListRouter: TodoListRouterProtocol {    
    
    // MARK: - Properties
    
    weak var viewController: TodoListViewController?
    
    // MARK: - TodoListRouterProtocol Methods
    
    static func createModule() -> TodoListViewController {
        let view = TodoListViewController()
        let interactor = TodoListInteractor(
            networkManager: DependencyContainer.shared.container.resolve(NetworkManagerProtocol.self)!,
            coreDataManager: DependencyContainer.shared.container.resolve(CoreDataManager.self)!
        )
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
    
    func presentTodoDetailsVC(todo: Todo?) {
        let todoDetailsViewController = TodoDetailsRouter.createModule(with: todo)
        viewController?.navigationController?.pushViewController(todoDetailsViewController, animated: true)
    }
    
    func presentShareSheet(todoTitle: String) {
        let activityViewController = UIActivityViewController(activityItems: [todoTitle], applicationActivities: nil)
        viewController?.present(activityViewController, animated: true)
    }
    
    func presentErrorAlert(alert: UIAlertController) {
        viewController?.present(alert, animated: true)
    }
    
    func presentDeleteAllTodosAlert(alert: UIAlertController) {
        viewController?.present(alert, animated: true)
    }
}
