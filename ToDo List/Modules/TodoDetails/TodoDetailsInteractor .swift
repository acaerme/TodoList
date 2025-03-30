import Foundation

final class TodoDetailsInteractor: TodoDetailsInteractorProtocol {

    // MARK: - Properties

    weak var presenter: TodoDetailsPresenterProtocol?

    // MARK: - TodoDetailsInteractorProtocol Methods

    func handleCreateTodo(title: String, description: String) {
        guard !title.isEmpty || !description.isEmpty else { return }

        let newTodo = Todo(
            id: UUID(),
            title: title,
            description: description,
            date: Date(),
            completed: false
        )

        NotificationCenter.default.post(
            name: Notification.Name("TodoAddedOrUpdated"),
            object: nil,
            userInfo: ["todo": newTodo]
        )

        presenter?.finishedHandlingTodo()
    }

    func handleEditTodo(id: UUID, newTitle: String, newDescription: String,
                        oldTitle: String, oldDescription: String, completed: Bool) {

        if newTitle.isEmpty && newDescription.isEmpty {
            NotificationCenter.default.post(
                name: Notification.Name("TodoDeleted"),
                object: nil,
                userInfo: ["todoId": id]
            )
            presenter?.finishedHandlingTodo()
            return
        }

        guard newTitle != oldTitle || newDescription != oldDescription else {
            presenter?.finishedHandlingTodo()
            return
        }

        let updatedTodo = Todo(
            id: id,
            title: newTitle,
            description: newDescription,
            date: Date(),
            completed: completed
        )

        NotificationCenter.default.post(
            name: Notification.Name("TodoAddedOrUpdated"),
            object: nil,
            userInfo: ["todo": updatedTodo]
        )

        presenter?.finishedHandlingTodo()
    }
}
