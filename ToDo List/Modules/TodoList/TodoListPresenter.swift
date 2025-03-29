import Foundation
import UIKit

// MARK: - TodoListPresenter

final class TodoListPresenter: TodoListPresenterProtocol {

    // MARK: - Properties

    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorProtocol?
    var router: TodoListRouterProtocol?

    // MARK: - Initialization

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoAddedorUpdated(_:)),
                                               name: NSNotification.Name("TodoAddedOrUpdated"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(todoDeleted(_:)),
                                               name: NSNotification.Name("TodoDeleted"),
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
            if !todos.isEmpty {
                view?.update(with: todos)
            } else {
                view?.enterNoTodosState()
            }

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

        interactor?.delete(id: todo.id)
    }

    func shareButtonTapped(todo: Todo) {
        let title = todo.title ?? ""

        router?.presentShareSheet(todoTitle: title)
    }

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

    // MARK: - Notification Handlers

    @objc private func todoAddedorUpdated(_ notification: Notification) {
        guard let newTodo = notification.userInfo?["todo"] as? Todo else { return }
        interactor?.addOrUpdate(todo: newTodo)
    }

    @objc private func todoDeleted(_ notification: Notification) {
        guard let todoId = notification.userInfo?["todoId"] as? UUID else { return }
        interactor?.delete(id: todoId)
    }
}
