import UIKit
import SnapKit

// MARK: - TodoDetailsViewController

class TodoDetailsViewController: UIViewController {
    
    // MARK: - Properties
    
    var presenter: TodoDetailsPresenterProtocol?
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.backgroundColor = .systemBackground
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .label
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        textField.textAlignment = .left
        textField.backgroundColor = .systemBackground
        textField.returnKeyType = .done
        return textField
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .label
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .systemBackground
        textView.layer.cornerRadius = 12
        textView.isEditable = true
        textView.isScrollEnabled = false
        return textView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureTextField()
        setupLayout()
        setupGesture()
        presenter?.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.handleTodo(title: titleTextField.text,
                              description: descriptionTextView.text)
    }
    
    // MARK: - Configurations
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func configureTextField() {
        titleTextField.delegate = self
    }
    
    // MARK: - Setup Layout
    
    private func setupLayout() {
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
    
    // MARK: - Actions
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - TodoDetailsViewProtocol

extension TodoDetailsViewController: TodoDetailsViewProtocol {
    func makeTitleTextFieldFirstResponder() {
        titleTextField.becomeFirstResponder()
    }
    
    func configureContent(date: String, title: String, description: String) {
        dateLabel.text = date
        titleTextField.text = title
        descriptionTextView.text = description
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
