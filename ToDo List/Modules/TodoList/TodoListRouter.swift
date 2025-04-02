import UIKit

// MARK: - TodoListRouter

final class TodoListRouter: TodoListRouterProtocol {
    
    // MARK: - Properties
    
    weak var viewController: TodoListViewController?
    
    // MARK: - Static Methods
    
    static func createModule() -> TodoListViewController {
        let view = TodoListViewController()
        let interactor = TodoListInteractor(
            networkManager: DependencyContainer.shared.container.resolve(NetworkManagerProtocol.self)!,
            coreDataManager: DependencyContainer.shared.container.resolve(CoreDataManagerProtocol.self)!
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
    
    // MARK: - TodoListRouterProtocol Methods
    
    func presentTodoDetailsVC(todo: Todo?) {
        let todoDetailsViewController = TodoDetailsRouter.createModule(with: todo)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.navigationController?.pushViewController(todoDetailsViewController, animated: true)
        }
    }
    
    func presentShareSheet(todoTitle: String) {
        let activityViewController = UIActivityViewController(activityItems: [todoTitle], applicationActivities: nil)
        presentViewController(activityViewController)
    }
    
    func presentAlert(alert: UIAlertController) {
        presentViewController(alert)
    }
    
    // MARK: - Private Methods
    
    private func presentViewController(_ viewControllerToPresent: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewController?.present(viewControllerToPresent, animated: true)
        }
    }
}
