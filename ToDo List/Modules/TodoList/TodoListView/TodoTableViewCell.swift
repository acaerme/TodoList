import UIKit
import SnapKit

protocol TodoTableViewCellDelegate: AnyObject {
    func didToggleTodo(_ updatedTodo: Todo)
}

class TodoTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var todo: Todo?
    weak var delegate: TodoTableViewCellDelegate?
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private let completedButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemYellow
        return button
    }()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupView()
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        contentView.addSubview(completedButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        completedButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(completedButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: - Helper Methods
    
    func updateCompletionUI(with completed: Bool) {
        let title = todo?.title ?? ""
        let attributedText = NSMutableAttributedString(string: title)
        if completed {
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: NSRange(location: 0, length: title.count))
        }
        titleLabel.attributedText = attributedText
        
        let imageName = completed ? "checkmark.circle.fill" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func configure(with todo: Todo) {
        self.todo = todo
        descriptionLabel.text = todo.description
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateLabel.text = dateFormatter.string(from: todo.date).replacingOccurrences(of: ".", with: "/")
        updateCompletionUI(with: todo.completed)
    }
    
    // MARK: - Actions
    
    @objc private func completedButtonTapped() {
        guard var todo = todo else { return }
        todo.completed.toggle()
        updateCompletionUI(with: todo.completed)
        delegate?.didToggleTodo(todo)
    }
    
    // MARK: - Touch Handling
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonPoint = completedButton.convert(point, from: self)
        if completedButton.bounds.contains(buttonPoint) {
            return completedButton.hitTest(buttonPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }
}
