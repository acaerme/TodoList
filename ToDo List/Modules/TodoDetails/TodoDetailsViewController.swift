import UIKit
import SnapKit

enum TodoDetailsMode {
    case creating
    case editing
}

final class TodoDetailsViewController: UIViewController, TodoDetailsViewProtocol {
    
    // MARK: - Properties
    
    var presenter: TodoDetailsPresenterProtocol?
    private var todo: Todo?
    private var mode: TodoDetailsMode
    
    // MARK: - UI Components
    
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
        label.font = UIFont.systemFont(ofSize: 14)
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
        if let todo = todo {
            self.todo = todo
            self.mode = .editing
        } else {
            self.mode = .creating
            // Auto-focusing will be handled in viewDidAppear.
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTextField()
        setupUIComponents()
        setupGesture()
        configureContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mode == .creating {
            titleTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.handleTodo(title: titleTextField.text,
                              description: descriptionTextView.text,
                              mode: mode,
                              todo: todo)
    }
    
    // MARK: - UI Setup Methods
    
    private func configureView() {
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureTextField() {
        titleTextField.delegate = self
    }
    
    private func setupUIComponents() {
        setupScrollView()
        addSubviews()
        setupConstraints()
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
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureContent() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = formatter.string(from: Date())
        
        if let todo = todo {
            titleTextField.text = todo.title
            descriptionTextView.text = todo.description ?? ""
        } else {
            titleTextField.text = ""
            descriptionTextView.text = ""
        }
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
// MARK: - UITextFieldDelegate

extension TodoDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        descriptionTextView.becomeFirstResponder()
        return true
    }
}
