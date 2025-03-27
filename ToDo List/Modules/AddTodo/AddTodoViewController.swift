import UIKit
import SnapKit

final class AddTodoViewController: UIViewController, AddTodoViewProtocol {
    
    // MARK: - Properties
    
    var presenter: AddTodoPresenterProtocol?
    
    // MARK: - UI Elements
    
    private let formContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .darkGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.textColor = .white
        return textField
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .darkGray.withAlphaComponent(0.2)
        textView.layer.cornerRadius = 10
        textView.layer.masksToBounds = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemYellow, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        addSubviews()
        setupConstraints()
        setupActionsAndDelegates()
    }
    
    // MARK: - Setup Methods
    
    private func addSubviews() {
        view.addSubview(formContainerView)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        
        formContainerView.addSubview(titleLabel)
        formContainerView.addSubview(titleTextField)
        formContainerView.addSubview(descriptionLabel)
        formContainerView.addSubview(descriptionTextView)
    }
    
    private func setupConstraints() {
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        
        formContainerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().inset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(formContainerView.snp.top)
            make.left.right.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalTo(formContainerView.snp.bottom)
        }
    }
    
    private func setupActionsAndDelegates() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        titleTextField.addTarget(self, action: #selector(titleTextFieldChanged), for: .editingChanged)
        
        titleTextField.delegate = self
        descriptionTextView.delegate = self
    }
    
    // MARK: - UI Actions
    
    @objc private func saveButtonTapped() {
        let todo = Todo(
            title: titleTextField.text ?? "",
            description: descriptionTextView.text.isEmpty ? nil : descriptionTextView.text,
            date: Date(),
            completed: false
        )
        
        presenter?.saveButtonTapped(todo: todo)
    }
    
    @objc private func cancelButtonTapped() {
        presenter?.cancelButtonTapped()
    }
    
    @objc private func titleTextFieldChanged() {
        let hasText = (titleTextField.text ?? "").isEmpty == false
        saveButton.isEnabled = hasText
        saveButton.setTitleColor(hasText ? .systemYellow : .systemGray, for: .normal)
    }
}

// MARK: - UITextFieldDelegate, UITextViewDelegate

extension AddTodoViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
