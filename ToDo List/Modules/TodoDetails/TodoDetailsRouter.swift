import UIKit

final class TodoDetailsRouter: TodoDetailsRouterProtocol {
    
    // MARK: - Properties
    
    weak var viewController: TodoDetailsViewController?
    
    // MARK: - Module Setup
    
    static func createModule(with todo: Todo?) -> TodoDetailsViewController {
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
    
    // MARK: - Navigation
    
    func dismissVC() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
