import Foundation
import UIKit

// MARK: - TodoListViewProtocol

protocol TodoListViewProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    func update(with viewModel: TodoListViewModel)
}

// MARK: - TodoListInteractorProtocol

protocol TodoListInteractorProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    
    func fetchTodos()
    func filterTodos(with searchText: String, completion: @escaping (([Todo]) -> Void))
    func updateTodo(updatedTodo: Todo)
    func delete(id: UUID)
    func deleteAllTodos()
}

// MARK: - TodoListPresenterProtocol

protocol TodoListPresenterProtocol: AnyObject {
    var view: TodoListViewProtocol? { get set }
    var interactor: TodoListInteractorProtocol? { get set }
    var router: TodoListRouterProtocol? { get set }
    
    func viewDidLoad()
    func updateTodosList(with result: Result<[Todo], Error>)
    func didSelectTodo(todo: Todo)
    func newTodoButtonTapped()
    func toggleTodo(todo: Todo)
    func searchForTodos(with searchText: String)
    func editButtonTapped(todo: Todo?)
    func deleteButtonTapped(todo: Todo?)
    func shareButtonTapped(todo: Todo)
    func deleteAllTodosButtonTapped()
    func presentStandardErrorAlert()
    func contextMenuConfiguration(for todo: Todo, at indexPath: IndexPath) -> UIContextMenuConfiguration
}

// MARK: - TodoListRouterProtocol

protocol TodoListRouterProtocol: AnyObject {
    var viewController: TodoListViewController? { get set }
    
    static func createModule() -> TodoListViewController
    func presentTodoDetailsVC(todo: Todo?)
    func presentShareSheet(todoTitle: String)
    func presentAlert(alert: UIAlertController)
}
