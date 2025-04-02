import Foundation

// MARK: - TodoDetailsInteractor

final class TodoDetailsInteractor: TodoDetailsInteractorProtocol {
    
    // MARK: - Properties
    
    weak var presenter: TodoDetailsPresenterProtocol?
    private let coreDataManager: CoreDataManagerProtocol

    // MARK: - Initialization
    
    init(coreDataManager: CoreDataManagerProtocol) {
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - Public Methods
    
    func handleCreateTodo(title: String, description: String) {
        guard !title.isEmpty || !description.isEmpty else { return }
        
        let newTodo = Todo(id: UUID(),
                           title: title,
                           description: description,
                           date: Date(),
                           completed: false)
        
        coreDataManager.createTodo(newTodo: newTodo) { [weak self] error in
            self?.handleCoreDataResult(error: error, notificationName: "TodoAdded", userInfo: ["todo": newTodo])
        }
    }
    
    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                       oldTitle: String, oldDescription: String, completed: Bool) {
        
        if newTitle.isEmpty && newDescription.isEmpty {
            deleteTodo(id: id)
            return
        }
        
        guard newTitle != oldTitle || newDescription != oldDescription else {
            return
        }
        
        let updatedTodo = Todo(id: id,
                             title: newTitle,
                             description: newDescription,
                             date: Date(),
                             completed: completed)
        
        coreDataManager.updateTodo(todo: updatedTodo) { [weak self] error in
            self?.handleCoreDataResult(error: error, notificationName: "TodoEdited", userInfo: ["todo": updatedTodo])
        }
    }
    
    // MARK: - Private Methods
    
    private func deleteTodo(id: UUID) {
        coreDataManager.deleteTodo(id: id) { [weak self] error in
            self?.handleCoreDataResult(error: error, notificationName: "TodoDeleted", userInfo: ["todoId": id])
        }
    }
    
    private func handleCoreDataResult(error: Error?, notificationName: String, userInfo: [AnyHashable: Any]? = nil) {
        guard error == nil else {
            NotificationCenter.default.post(name: Notification.Name("ErrorOccuredWithCoreData"), object: nil)
            return
        }
        
        NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil, userInfo: userInfo)
    }
}
