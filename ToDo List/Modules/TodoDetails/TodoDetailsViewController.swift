import UIKit
import SnapKit

enum TodoDetailsMode {
    case creating
    case editing
}

final class TodoDetailsViewController: UIViewController, TodoDetailsViewProtocol, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var presenter: TodoDetailsPresenterProtocol?
    private var todo: Todo?
    private var mode: TodoDetailsMode
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.textAlignment = .left
        textField.backgroundColor = .clear
        textField.returnKeyType = .done
        return textField
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 12
        textView.isEditable = true
        textView.isScrollEnabled = false
        return textView
    }()
    
    // MARK: - Initializers
    
    init(todo: Todo? = nil) {
        if todo == nil {
            self.todo = Todo(
                id: UUID(),
                title: "",
                description: nil,
                date: Date(),
                completed: false)
            
            self.mode = .creating
            
            titleTextField.becomeFirstResponder()
        } else {
            self.todo = todo
            self.mode = .editing
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.largeTitleDisplayMode = .never
        
        titleTextField.delegate = self
        
        configureUI()
        setupScrollView()
        addSubviews()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let presenter = presenter else { return }

        if mode == .creating {
            if let title = titleTextField.text, !title.isEmpty {
                let newTodo = Todo(id: UUID(), title: title, description: descriptionTextView.text, date: Date(), completed: false)
                presenter.saveButtonTapped(todo: newTodo)
                NotificationCenter.default.post(name: NSNotification.Name("TodoAddedOrUpdated"), object: nil, userInfo: ["todo": newTodo])
            }
        } else if mode == .editing {
            guard let todo = todo else { return }

            let updatedTitle = titleTextField.text ?? ""
            let updatedDescription = descriptionTextView.text ?? ""

            if updatedTitle != todo.title || updatedDescription != todo.description {
                let updatedTodo = Todo(id: todo.id, title: updatedTitle, description: updatedDescription, date: todo.date, completed: todo.completed)
                presenter.saveButtonTapped(todo: updatedTodo)
                NotificationCenter.default.post(name: NSNotification.Name("TodoAddedOrUpdated"), object: nil, userInfo: ["todo": updatedTodo])
            }
        }
    }
    
    // MARK: - UI Setup
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func configureUI() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let todo = todo {
            titleTextField.text = todo.title
            dateLabel.text = formatter.string(from: Date())
            descriptionTextView.text = todo.description ?? ""
        } else {
            titleTextField.text = ""
            dateLabel.text = formatter.string(from: Date())
            descriptionTextView.text = ""
        }
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
    }
    
    private func addSubviews() {
        contentView.addSubview(titleTextField)
        contentView.addSubview(dateLabel)
        contentView.addSubview(descriptionTextView)
    }
    
    private func setupConstraints() {
        titleTextField.snp.makeConstraints { maker in
            maker.top.equalTo(contentView.snp.top).offset(20)
            maker.left.right.equalToSuperview().inset(20)
            maker.height.equalTo(40)
        }
        
        dateLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleTextField.snp.bottom).offset(8)
            maker.left.equalToSuperview().inset(20)
        }
        
        descriptionTextView.snp.makeConstraints { maker in
            maker.top.equalTo(dateLabel.snp.bottom).offset(20)
            maker.left.right.equalToSuperview().inset(20)
            maker.bottom.equalTo(contentView.snp.bottom).inset(20)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        descriptionTextView.becomeFirstResponder()
        return true
    }
}
