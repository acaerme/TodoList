import UIKit

class AddTodoRouter: AddTodoRouterProtocol {
    
    // MARK: - Properties
    
    weak var viewController: AddTodoViewController?
    
    // MARK: - Module Setup
    
    static func createModule() -> AddTodoViewController {
        let view = AddTodoViewController()
        let presenter = AddTodoPresenter()
        let interactor = AddTodoInteractor()
        let router = AddTodoRouter()
        
        // Inject dependencies
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
