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
        
        coreDataManager.createTodo(newTodo: newTodo) { error in
            if error == nil {
                guard error == nil else {
                    NotificationCenter.default.post(
                        name: Notification.Name("ErrorOccuredWithCoreData"),
                        object: nil
                    )
                    return
                }
                
                NotificationCenter.default.post(
                    name: Notification.Name("TodoAdded"),
                    object: nil,
                    userInfo: ["todo": newTodo]
                )
            }
        }
    }
    
    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                       oldTitle: String, oldDescription: String, completed: Bool) {
        
        if newTitle.isEmpty && newDescription.isEmpty {
            coreDataManager.deleteTodo(id: id) { error in
                guard error == nil else {
                    NotificationCenter.default.post(
                        name: Notification.Name("ErrorOccuredWithCoreData"),
                        object: nil
                    )
                    return
                }
                
                NotificationCenter.default.post(
                    name: Notification.Name("TodoDeleted"),
                    object: nil,
                    userInfo: ["todoId": id]
                )
            }
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
        
        coreDataManager.updateTodo(todo: updatedTodo) { error in
            guard error == nil else {
                NotificationCenter.default.post(
                    name: Notification.Name("ErrorOccuredWithCoreData"),
                    object: nil
                )
                return
            }
            
            NotificationCenter.default.post(
                name: Notification.Name("TodoEdited"),
                object: nil,
                userInfo: ["todo": updatedTodo]
            )
        }
    }
}
