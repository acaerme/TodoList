import Foundation

class AddTodoPresenter: AddTodoPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: AddTodoViewProtocol?
    var interactor: AddTodoInteractorProtocol?
    var router: AddTodoRouterProtocol?
    
    // MARK: - User Actions
    
    func cancelButtonTapped() {
        router?.dismissVC()
    }
    
    func saveButtonTapped(todo: Todo) {
        interactor?.save(todo: todo)
    }
    
    // MARK: - Interactor Callback
    
    func didSaveTodo() {
        router?.dismissVC()
    }
}
