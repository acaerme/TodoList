// File: TodoDetailsViewController.swift
import UIKit
import SnapKit

final class TodoDetailsViewController: UIViewController, TodoDetailsViewProtocol {
    
    // MARK: - Properties
    
    var presenter: TodoDetailsPresenterProtocol?
    private var todo: Todo?
    
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
        textField.placeholder = "Enter title"
        return textField
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
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
            
            titleTextField.becomeFirstResponder()
        } else {
            self.todo = todo
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
        
        configureUI()
        setupScrollView()
        addSubviews()
        setupConstraints()
    }
    
    // MARK: - UI Setup
    
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
            maker.top.equalTo(titleTextField.snp.bottom).offset(12)
            maker.left.right.equalToSuperview().inset(20)
            maker.height.equalTo(20)
        }
        
        descriptionTextView.snp.makeConstraints { maker in
            maker.top.equalTo(dateLabel.snp.bottom).offset(20)
            maker.left.right.equalToSuperview().inset(20)
            maker.bottom.equalTo(contentView.snp.bottom).inset(20)
        }
    }
}
