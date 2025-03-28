import Foundation

final class TodoDetailsPresenter: TodoDetailsPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
    
    // MARK: - Public Methods
    
    func handleTodo(title: String?, description: String?, mode: TodoDetailsMode, todo: Todo?) {
        let title = title ?? ""
        let description = description ?? ""
        
        switch mode {
        case .editing:
            guard let todo = todo else { return }
            interactor?.handleEditTodo(id: todo.id,
                                       newTitle: title,
                                       newDescription: description,
                                       oldTitle: todo.title ?? "",
                                       oldDescription: todo.description ?? "")
        case .creating:
            interactor?.handleCreateTodo(title: title, description: description)
        }
    }
    
    func finishedHandlingTodo() {
        router?.dismissVC()
    }
}
