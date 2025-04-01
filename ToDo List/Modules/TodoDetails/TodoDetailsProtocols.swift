import Foundation

// MARK: - TodoDetailsViewProtocol

protocol TodoDetailsViewProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
    
    func makeTitleTextFieldFirstResponder()
    func configureContent(date: String, title: String, description: String)
}

// MARK: - TodoDetailsInteractorProtocol

protocol TodoDetailsInteractorProtocol: AnyObject {
    var presenter: TodoDetailsPresenterProtocol? { get set }
    
    func handleCreateTodo(title: String, description: String)
    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                        oldTitle: String, oldDescription: String, completed: Bool)
}

// MARK: - TodoDetailsPresenterProtocol

protocol TodoDetailsPresenterProtocol: AnyObject {
    var view: TodoDetailsViewProtocol? { get set }
    var interactor: TodoDetailsInteractorProtocol? { get set }
    var router: TodoDetailsRouterProtocol? { get set }
    
    func viewDidLoad()
    func handleTodo(title: String?, description: String?)
}

// MARK: - TodoDetailsRouterProtocol

protocol TodoDetailsRouterProtocol: AnyObject {
    var viewController: TodoDetailsViewController? { get set }
    static func createModule(with todo: Todo?) -> TodoDetailsViewController
}
