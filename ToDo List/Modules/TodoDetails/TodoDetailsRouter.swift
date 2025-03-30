import UIKit

final class TodoDetailsRouter: TodoDetailsRouterProtocol {

    // MARK: - Properties

    weak var viewController: TodoDetailsViewController?

    // MARK: - TodoDetailsRouterProtocol Methods

    static func createModule(with todo: Todo?) -> TodoDetailsViewController {
        let view = TodoDetailsViewController()
        let interactor = TodoDetailsInteractor()
        let presenter = TodoDetailsPresenter(todo: todo)
        let router = TodoDetailsRouter()

        view.presenter = presenter
        interactor.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        router.viewController = view

        return view
    }

    func dismissVC() {
        viewController?.dismiss(animated: true, completion: nil)
    }
}
