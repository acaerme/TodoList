import UIKit
import SnapKit

final class TodoListViewController: UIViewController, TodoListViewProtocol {

    // MARK: - Properties

    var presenter: TodoListPresenterProtocol?
    private var todos: [Todo] = []

    // MARK: - UI Elements

    private let todoTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoTableViewCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        return tableView
    }()

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search Todos"
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    private let bottomTabBar: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray.withAlphaComponent(0.2)
        return view
    }()

    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let newTodoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupTableView()
        presenter?.viewDidLoad()
    }

    // MARK: - TodoListViewProtocol

    func update(with todos: [Todo]) {
        self.todos = todos

        let count = todos.count
        let word = getTaskWord(for: count)

        DispatchQueue.main.async { [weak self] in
            self?.taskCountLabel.text = "\(count) \(word)"
            self?.todoTableView.reloadData()
        }
    }

    // MARK: - Setup Methods

    private func setupView() {
        view.backgroundColor = .black
        title = "Задачи"

        addSubviews()
        setupConstraints()

        newTodoButton.addTarget(self, action: #selector(newTodoButtonTapped), for: .touchUpInside)
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }

    private func addSubviews() {
        view.addSubview(todoTableView)
        view.addSubview(bottomTabBar)
        bottomTabBar.addSubview(taskCountLabel)
        bottomTabBar.addSubview(newTodoButton)
    }

    private func setupConstraints() {
        todoTableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomTabBar.snp.top)
        }

        bottomTabBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(80)
        }

        taskCountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        newTodoButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(20)
        }
    }

    private func setupTableView() {
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .black
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }

    // MARK: - Helper Methods

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

    // MARK: - Actions

    @objc private func newTodoButtonTapped() {
        presenter?.newTodoButtonTapped()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTableViewCell", for: indexPath) as? TodoTableViewCell else {
            return UITableViewCell()
        }
        let todo = todos[indexPath.row]
        cell.configure(with: todo)
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let todo = todos[indexPath.row]
        presenter?.didSelectTodo(todo: todo)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let todo = todos[indexPath.row]
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: {
            return TodoPreviewController(todo: todo)
        }) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.presenter?.editButtonTapped(todo: todo)
            }
            
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter?.deleteButtonTapped(todo: todo)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}

// MARK: - TodoTableViewCellDelegate

extension TodoListViewController: TodoTableViewCellDelegate {
    func didToggleTodo(_ updatedTodo: Todo) {
        presenter?.toggleTodoCompletion(for: updatedTodo)
    }
}

// MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.searchForTodos(with: searchText)
    }
}
