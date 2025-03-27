import Foundation

final class TodoDetailsPresenter: TodoDetailsPresenterProtocol {
    weak var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
}
