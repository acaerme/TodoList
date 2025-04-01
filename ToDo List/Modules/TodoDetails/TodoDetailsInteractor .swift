import Foundation

final class TodoDetailsInteractor: TodoDetailsInteractorProtocol {
    weak var presenter: TodoDetailsPresenterProtocol?
    private let coreDataManager: CoreDataManager
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func handleCreateTodo(title: String, description: String) {
        guard !title.isEmpty || !description.isEmpty else { return }
        
        let newTodo = Todo(id: UUID(),
                          title: title,
                          description: description,
                          date: Date(),
                          completed: false)
        
        coreDataManager.createTodo(newTodo: newTodo, completion: nil)
    }
    
    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                       oldTitle: String, oldDescription: String, completed: Bool) {
        
        if newTitle.isEmpty && newDescription.isEmpty {
            coreDataManager.deleteTodo(id: id, completion: nil)
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
        
        coreDataManager.updateTodo(todo: updatedTodo, completion: nil)
    }
}
