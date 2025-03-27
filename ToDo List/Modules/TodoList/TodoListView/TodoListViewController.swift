//
//  TodoListViewController.swift
//  ToDo List
//
//  Created by Islam Elikhanov on 26/03/2025.
//

import UIKit
import SnapKit

class TodoListViewController: UIViewController, TodoListViewProtocol {
    
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
    
    // MARK: - Protocol Methods
    
    func update(with todos: [Todo]) {
        self.todos = todos
        
        DispatchQueue.main.async { [weak self] in
            self?.todoTableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        title = "Задачи"
        setupNavigationBar()
        
        presenter?.viewDidLoad()
        
        addSubviews()
        setupConstraints()
        setupTableView()
    }
    
    // MARK: - UI Setup
    
    private func addSubviews() {
        view.addSubview(todoTableView)
    }
    
    private func setupConstraints() {
        todoTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
    
    // MARK: - Private Methods
    
    private func setupTableView() {
        todoTableView.dataSource = self
        todoTableView.delegate = self
    }
}

// MARK: - TableView DataSource & Delegate

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTableViewCell", for: indexPath) as? TodoTableViewCell
        else {
            return UITableViewCell()
        }
        
        let todo = todos[indexPath.row]
        cell.configure(with: todo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let todo = todos[indexPath.row]
        presenter?.didSelectTodo(todo: todo)
    }
}

