import Foundation

class AddTodoInteractor: AddTodoInteractorProtocol {
    
    // MARK: - Properties
    
    weak var presenter: AddTodoPresenterProtocol?
    
    // MARK: - Business Logic
    
    func save(todo: Todo) {
        
        NotificationCenter.default.post(
            name: NSNotification.Name("TodoAdded"),
            object: nil,
            userInfo: ["todo": todo]
        )
        
        presenter?.didSaveTodo()
    }
}
