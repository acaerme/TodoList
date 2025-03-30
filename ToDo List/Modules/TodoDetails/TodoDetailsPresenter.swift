import Foundation

// MARK: - TodoDetailsMode

enum TodoDetailsMode {
    case creating
    case editing
}

final class TodoDetailsPresenter: TodoDetailsPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: TodoDetailsViewProtocol?
    var interactor: TodoDetailsInteractorProtocol?
    var router: TodoDetailsRouterProtocol?
    private var todo: Todo?
    private var mode: TodoDetailsMode
    
    var isCreating: Bool {
        return mode == .creating
    }
    
    // MARK: - Initializers
    
    init(todo: Todo?) {
        if todo == nil {
            mode = .creating
        } else {
            self.todo = todo
            mode = .editing
        }
    }
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        let date = getFormattedDate()
        let title = getTitleText()
        let description = getDescriptionText()
        view?.configureContent(date: date, title: title, description: description)
        
        if mode == .creating {
            view?.makeTitleTextFieldFirstResponder()
        }
    }
    
    func handleTodo(title: String?, description: String?) {
        let title = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = description?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        switch mode {
        case .editing:
            guard let todo = todo else { return }
            interactor?.handleEditTodo(id: todo.id,
                                       newTitle: title,
                                       newDescription: description,
                                       oldTitle: todo.title ?? "",
                                       oldDescription: todo.description ?? "",
                                       completed: todo.completed)
        case .creating:
            interactor?.handleCreateTodo(title: title, description: description)
        }
    }
    
    func finishedHandlingTodo() {
        router?.dismissVC()
    }
    
    // MARK: - Private Methods
    
    private func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: todo?.date ?? Date()) // later
    }
    
    private func getTitleText() -> String {
        return todo?.title ?? ""
    }
    
    private func getDescriptionText() -> String {
        return todo?.description ?? ""
    }
}
