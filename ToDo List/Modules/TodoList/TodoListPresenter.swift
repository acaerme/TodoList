import Foundation
import UIKit

// MARK: - TodoListPresenter

final class TodoListPresenter: TodoListPresenterProtocol {

    // MARK: - Properties

    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?

    // MARK: - TodoListPresenterProtocol Methods

    func viewDidLoad() {
        interactor?.fetchTodos()
    }

    func updateTodosList(with result: Result<[Todo], Error>) {
        switch result {
        case .success(let todos):
            if !todos.isEmpty {
                view?.update(with: todos)
            } else {
                view?.enterNoTodosState()
            }

        case .failure(let error):
            // later handle error
            print("Error fetching todos")
        }
    }

    func didSelectTodo(todo: Todo) {
        router?.showDetails(for: todo)
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
        interactor?.deleteAllTodos()
    }

    func shareButtonTapped(todo: Todo) {
        let title = todo.title ?? ""

        router?.presentShareSheet(todoTitle: title)
    }

    func getTaskCountText(for count: Int) -> String {
        let word = getTaskWord(for: count)
        return "\(count) \(word)"
    }

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
