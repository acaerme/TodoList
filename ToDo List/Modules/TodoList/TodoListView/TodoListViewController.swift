import UIKit
import SnapKit

// MARK: - TodoListViewController

final class TodoListViewController: UIViewController {
    
    // MARK: - Properties
    
    var presenter: TodoListPresenterProtocol?
    private var todos: [Todo] = []
    private var searchController: UISearchController!
    
    // MARK: - UI Elements
    
    private let todoTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoTableViewCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.isHidden = true
        return tableView
    }()
    
    private let bottomTabBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.2)
        return view
    }()
    
    private let taskCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let newTodoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    private let deleteAllTodosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemYellow
        return button
    }()
    
    private let noTodosLabel: UILabel = {
        let label = UILabel()
        label.text = "No Todos"
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let noTodosIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupLayout()
        setupNavigationBar()
        setupSearchController()
        setupTableView()
        setupActions()
        presenter?.viewDidLoad()
    }
    
    // later
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateUIForColorScheme()
        }
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        title = "Задачи"
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(todoTableView)
        view.addSubview(bottomTabBar)
        bottomTabBar.addSubview(taskCountLabel)
        bottomTabBar.addSubview(newTodoButton)
        bottomTabBar.addSubview(deleteAllTodosButton)
        view.addSubview(noTodosIcon)
        view.addSubview(noTodosLabel)
    }
    
    private func setupConstraints() {
        todoTableView.snp.makeConstraints { maker in
            maker.top.left.right.equalToSuperview()
            maker.bottom.equalTo(bottomTabBar.snp.top)
        }
        
        bottomTabBar.snp.makeConstraints { maker in
            maker.left.right.bottom.equalToSuperview()
            maker.height.equalTo(80)
        }
        
        taskCountLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.centerX.equalToSuperview()
        }
        
        newTodoButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.right.equalToSuperview().inset(20)
        }
        
        deleteAllTodosButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(16)
            maker.left.equalToSuperview().inset(20)
        }
        
        noTodosIcon.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.centerY.equalToSuperview().offset(-20)
            maker.width.height.equalTo(40)
        }
        
        noTodosLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(noTodosIcon.snp.bottom).offset(8)
        }
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .systemYellow
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        searchController.searchBar.showsBookmarkButton = true
        let micImage = UIImage(systemName: "mic.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        searchController.searchBar.setImage(micImage, for: .bookmark, state: .normal)
        
        let searchIconImage = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        let leftImageView = UIImageView(image: searchIconImage)
        leftImageView.tintColor = .lightGray
        searchController.searchBar.searchTextField.leftView = leftImageView
        
        searchController.searchBar.delegate = self
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.backgroundColor = .systemGray6
        searchTextField.returnKeyType = .default
        searchTextField.enablesReturnKeyAutomatically = false
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
            .foregroundColor: UIColor.lightGray
        ])
        searchTextField.textColor = .label
    }
    
    private func setupTableView() {
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        newTodoButton.addTarget(self, action: #selector(newTodoButtonTapped), for: .touchUpInside)
        deleteAllTodosButton.addTarget(self, action: #selector(deleteAllTodosButtonTapped), for: .touchUpInside)
    }
    
    @objc private func newTodoButtonTapped() {
        presenter?.newTodoButtonTapped()
    }
    
    @objc private func deleteAllTodosButtonTapped() {
        
        // later with alert
        presenter?.deleteAllTodosButtonTapped()
    }
    
    // MARK: - UI Updates
    
    private func updateUIForColorScheme() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.scrollEdgeAppearance?.backgroundColor = .systemBackground
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        taskCountLabel.textColor = .label
        todoTableView.reloadData()
        
        if let searchTextField = searchController?.searchBar.searchTextField {
            searchTextField.textColor = .label
            searchTextField.backgroundColor = .systemGray6
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [
                .foregroundColor: UIColor.lightGray
            ])
        }
    }
}

// MARK: - TodoListViewProtocol

extension TodoListViewController: TodoListViewProtocol {
    func update(with todos: [Todo]) {
        self.todos = todos
        let taskCountText = presenter?.getTaskCountText(for: todos.count)
        
        DispatchQueue.main.async { [weak self] in
            self?.noTodosLabel.isHidden = true
            self?.noTodosIcon.isHidden = true
            self?.todoTableView.isHidden = false
            self?.taskCountLabel.isHidden = false
            self?.taskCountLabel.text = taskCountText
            self?.todoTableView.reloadData()
        }
    }
    
    func enterNoTodosState() {
        DispatchQueue.main.async { [weak self] in
            self?.noTodosLabel.isHidden = false
            self?.noTodosIcon.isHidden = false
            self?.todoTableView.isHidden = true
            self?.taskCountLabel.isHidden = true
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

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
        return presenter?.contextMenuConfiguration(for: todo, at: indexPath)
    }
}

// MARK: - TodoTableViewCellDelegate

extension TodoListViewController: TodoTableViewCellDelegate {
    func didToggleTodo(_ updatedTodo: Todo) {
        presenter?.toggleTodoCompletion(for: updatedTodo)
    }
}

// MARK: - UISearchResultsUpdating

extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.searchForTodos(with: searchController.searchBar.text ?? "")
    }
}

// MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsBookmarkButton = false
        searchBar.searchTextField.leftView = nil
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsBookmarkButton = true
        let micImage = UIImage(systemName: "mic.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        searchBar.setImage(micImage, for: .bookmark, state: .normal)
        
        let searchIconImage = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        let leftImageView = UIImageView(image: searchIconImage)
        leftImageView.tintColor = .lightGray
        searchController.searchBar.searchTextField.leftView = leftImageView
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let clearButton = searchBar.searchTextField.value(forKey: "clearButton") as? UIButton,
           let imageView = clearButton.imageView,
           let image = imageView.image {
            clearButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = .lightGray
        }
        presenter?.searchForTodos(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
