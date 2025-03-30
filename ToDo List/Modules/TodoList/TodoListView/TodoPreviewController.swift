import UIKit
import SnapKit

// MARK: - TodoPreviewController

final class TodoPreviewController: UIViewController {
    
    // MARK: - Properties
    
    private let todo: Todo
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Initializers
    
    init(todo: Todo) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupLabels()
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        view.backgroundColor = UIColor.previewVCBackgroundColor
    }
    
    // MARK: - Setup
    
    private func setupLabels() {
        if let titleText = todo.title, !titleText.isEmpty {
            titleLabel.text = titleText
        }
        
        if let descriptionText = todo.description, !descriptionText.isEmpty {
            descriptionLabel.text = descriptionText
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = formatter.string(from: todo.date)
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            maker.left.right.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(12)
            maker.left.right.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints { maker in
            maker.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            maker.left.right.equalToSuperview().inset(16)
            maker.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
}
