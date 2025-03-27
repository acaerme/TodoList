import UIKit
import SnapKit

class TodoDetailsViewController: UIViewController, TodoDetailsViewProtocol {
    
    // MARK: - Properties
    
    var presenter: TodoDetailsPresenterProtocol?
    private let todo: Todo
    private let initialTitle: String
    private let initialDescription: String?
    
    // MARK: - UI Elements
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .darkGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 10
        textField.textColor = .white
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .darkGray.withAlphaComponent(0.2)
        textView.layer.cornerRadius = 10
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        return textView
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Сохранить",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Initializer
    
    init(todo: Todo) {
        self.todo = todo
        self.initialTitle = todo.title
        self.initialDescription = todo.description
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = saveButton
        
        setupUI()
        setupActionsAndDelegates()
        populateInitialData()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }
    
    private func setupActionsAndDelegates() {
        titleTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        titleTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    private func populateInitialData() {
        titleTextField.text = initialTitle
        descriptionTextView.text = initialDescription
    }
    
    // MARK: - UI Actions
    
    @objc private func saveButtonTapped() {
        let updatedTodo = Todo(
            id: todo.id,
            title: titleTextField.text ?? "",
            description: descriptionTextView.text.isEmpty ? nil : descriptionTextView.text,
            date: Date(),
            completed: todo.completed
        )
        
        presenter?.saveButtonTapped(todo: updatedTodo)
    }
    
    @objc private func textDidChange() {
        updateSaveButtonState()
    }
    
    // MARK: - Helper Methods
    
    private func updateSaveButtonState() {
        let currentTitle = titleTextField.text ?? ""
        let currentDescription = descriptionTextView.text
        let hasChanged = (currentTitle != initialTitle) || (currentDescription != initialDescription)
        saveButton.isEnabled = hasChanged
    }
}

// MARK: - UITextFieldDelegate

extension TodoDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension TodoDetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
    }
}
