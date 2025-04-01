import Foundation
import UIKit

struct TodoListViewModel {
    let todos: [Todo]
    let taskCountText: String
    let isNoTodosHidden: Bool
    let isTableViewHidden: Bool
    let isTaskCountLabelHidden: Bool
}

// MARK: - TodoListPresenter

final class TodoListPresenter: TodoListPresenterProtocol {
    
    // MARK: - Properties
    
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?
    
    // MARK: - Lifecycle Methods
    
    func viewDidLoad() {
        interactor?.fetchTodos()
    }
    
    // MARK: - Data Handling Methods
    
    func updateTodosList(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            let viewModel = TodoListViewModel(
                todos: todos,
                taskCountText: self.getTaskCountText(for: todos.count),
                isNoTodosHidden: !todos.isEmpty,
                isTableViewHidden: todos.isEmpty,
                isTaskCountLabelHidden: todos.isEmpty
            )
            self.view?.update(with: viewModel)
        case .failure(_):
            let alert = UIAlertController(title: "Error", message: "Failed to fetch todos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.router?.presentErrorAlert(alert: alert)
        }
    }
    
    // MARK: - User Interaction Methods
    
    func didSelectTodo(todo: Todo) {
        router?.presentTodoDetailsVC(todo: todo)
    }
    
    func newTodoButtonTapped() {
        router?.presentTodoDetailsVC(todo: nil)
    }
    
    func toggleTodoCompletion(for updatedTodo: Todo) {
        interactor?.updateTodo(updatedTodo: updatedTodo)
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
        
        interactor?.delete(id: todo.id)
    }
    
    func deleteAllTodosButtonTapped() {
        let alert = UIAlertController(title: "Delete all todos",
                                      message: "Are you sure that you want to delete all todos? This action can not be undone.",
                                      preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.interactor?.deleteAllTodos()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.router?.presentErrorAlert(alert: alert)
    }
    
    func shareButtonTapped(todo: Todo) {
        let title = todo.title ?? ""
        
        router?.presentShareSheet(todoTitle: title)
    }
    
    // MARK: - Context Menu
    
    func contextMenuConfiguration(for todo: Todo, at indexPath: IndexPath) -> UIContextMenuConfiguration {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            return TodoPreviewController(todo: todo)
        }) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.editButtonTapped(todo: todo)
            }
            
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareButtonTapped(todo: todo)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteButtonTapped(todo: todo)
            }
            
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
    
    // MARK: - Helper Methods
    
    func getTaskCountText(for count: Int) -> String {
        let word = getTaskWord(for: count)
        return "\(count) \(word)"
    }
    
    private func getTaskWord(for count: Int) -> String {
        let rem100 = count % 100
        let rem10 = count % 10
        
        if rem100 >= 11 && rem100 <= 14 {
            return "задач"
        } else if rem10 == 1 {
            return "задача"
        } else if rem10 >= 2 && rem10 <= 4 {
            return "задачи"
        } else {
            return "задач"
        }
    }
}
