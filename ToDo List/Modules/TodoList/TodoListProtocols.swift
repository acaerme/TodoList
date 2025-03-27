import Foundation

// MARK: - TodoListViewProtocol

protocol TodoListViewProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    func update(with todos: [Todo])
}

// MARK: - TodoListInteractorProtocol

protocol TodoListInteractorProtocol: AnyObject {
    var presenter: TodoListPresenterProtocol? { get set }
    func fetchTodos()
    func filterTodos(with searchText: String)
    func toggleTodoCompletion(for updatedTodo: Todo)
    func addOrUpdate(todo: Todo)
    func delete(todo: Todo)
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
    func toggleTodoCompletion(for updatedTodo: Todo)
    func searchForTodos(with searchText: String)
    func editButtonTapped(todo: Todo?)
    func deleteButtonTapped(todo: Todo?)
}

// MARK: - TodoListRouterProtocol

protocol TodoListRouterProtocol: AnyObject {
    var viewController: TodoListViewController? { get set }
    static func createModule() -> TodoListViewController
    func showDetails(for todo: Todo)
    func presentTodoDetailsVC(todo: Todo?)
}
