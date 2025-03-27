import Foundation

final class TodoDetailsPresenter: TodoDetailsPresenterProtocol {
    weak var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
    
    func saveButtonTapped(todo: Todo) {
        // save
        router?.dismissVC()
    }
}
