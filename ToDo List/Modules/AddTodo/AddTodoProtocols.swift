// MARK: - View

protocol AddTodoViewProtocol: AnyObject {
    var presenter: AddTodoPresenterProtocol? { get set }
}

// MARK: - Interactor

protocol AddTodoInteractorProtocol: AnyObject {
    var presenter: AddTodoPresenterProtocol? { get set }
    func save(todo: Todo)
}

// MARK: - Presenter

protocol AddTodoPresenterProtocol: AnyObject {
    var view: AddTodoViewProtocol? { get set }
    var interactor: AddTodoInteractorProtocol? { get set }
    var router: AddTodoRouterProtocol? { get set }
    
    func cancelButtonTapped()
    func saveButtonTapped(todo: Todo)
    func didSaveTodo()
}

// MARK: - Router

protocol AddTodoRouterProtocol: AnyObject {
    var viewController: AddTodoViewController? { get set }
    
    static func createModule() -> AddTodoViewController
    func dismissVC()
}
