import Foundation

final class TodoListPresenter: TodoListPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?
    
    // MARK: - Initialization
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoAdded(_:)),
                                               name: NSNotification.Name("TodoAddedOrUpdated"),
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - TodoListPresenterProtocol Methods
    
    func viewDidLoad() {
        interactor?.fetchTodos()
    }
    
    func updateTodosList(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            view?.update(with: todos)
        case .failure(let error):
            print("Error fetching todos: \(error)")
        }
    }
    
    func didSelectTodo(todo: Todo) {
        router?.showDetails(for: todo)
    }
    
    func newTodoButtonTapped() {
        router?.presentTodoDetailsVC(todo: nil)
    }
    
    func toggleTodoCompletion(for updatedTodo: Todo) {
        interactor?.toggleTodoCompletion(for: updatedTodo)
    }
    
    func searchForTodos(with searchText: String) {
        interactor?.filterTodos(with: searchText)
    }
    
    func editButtonTapped(todo: Todo?) {
        guard let todo = todo else { return }
        
        router?.presentTodoDetailsVC(todo: todo)
    }
    
    func deleteButtonTapped(todo: Todo?) {
        guard let todo = todo else { return }
        
        interactor?.delete(todo: todo)
    }
    
    // MARK: - Notification Handlers
    
    @objc private func todoAdded(_ notification: Notification) {
        guard let newTodo = notification.userInfo?["todo"] as? Todo else { return }
        interactor?.addOrUpdate(todo: newTodo)
    }
}
