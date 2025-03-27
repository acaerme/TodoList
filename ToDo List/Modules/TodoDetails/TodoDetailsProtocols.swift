import Foundation

// MARK: - View Protocol

protocol TodoDetailsViewProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
}

// MARK: - Interactor Protocol

protocol TodoDetailsInteractorProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
}

// MARK: - Presenter Protocol

protocol TodoDetailsPresenterProtocol: AnyObject {
    var view: TodoDetailsViewProtocol? { get set }
    var interactor: TodoDetailsInteractorProtocol? { get set }
    var router: TodoDetailsRouterProtocol? { get set }
    
    func saveButtonTapped(todo: Todo)
}

// MARK: - Router Protocol

protocol TodoDetailsRouterProtocol: AnyObject {
    var viewController: TodoDetailsViewController? { get set }
    static func createModule(with: Todo) -> TodoDetailsViewController
}
