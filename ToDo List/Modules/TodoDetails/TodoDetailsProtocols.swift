import Foundation

// MARK: - TodoDetailsViewProtocol

protocol TodoDetailsViewProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
}

// MARK: - TodoDetailsInteractorProtocol

protocol TodoDetailsInteractorProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
    func handleCreateTodo(title: String, description: String)
    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                        oldTitle: String, oldDescription: String)
}

// MARK: - TodoDetailsPresenterProtocol

protocol TodoDetailsPresenterProtocol: AnyObject {
    var view: TodoDetailsViewProtocol? { get set }
    var interactor: TodoDetailsInteractorProtocol? { get set }
    var router: TodoDetailsRouterProtocol? { get set }
    
    func handleTodo(title: String?, description: String?, mode: TodoDetailsMode, todo: Todo?)
    func finishedHandlingTodo()
}

// MARK: - TodoDetailsRouterProtocol

protocol TodoDetailsRouterProtocol: AnyObject {
    var viewController: TodoDetailsViewController? { get set }
    static func createModule(with todo: Todo?) -> TodoDetailsViewController
    func dismissVC()
}
