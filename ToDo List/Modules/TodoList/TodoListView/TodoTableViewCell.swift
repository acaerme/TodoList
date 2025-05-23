import UIKit
import SnapKit

// MARK: - TodoTableViewCell

final class TodoTableViewCell: UITableViewCell {

    // MARK: - Properties

    private var todo: Todo?
    var selectCompletion: (() -> Void)?

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
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
        configureView()
        setupLayout()
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let buttonPoint = completedButton.convert(point, from: self)
        if completedButton.bounds.contains(buttonPoint) {
            return completedButton.hitTest(buttonPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }

    // MARK: - Configuration

    private func configureView() {
        backgroundColor = .systemBackground
    }

    // MARK: - Layout

    private func setupLayout() {
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
        completedButton.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(12)
            maker.leading.equalToSuperview().offset(16)
            maker.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(12)
            maker.leading.equalTo(completedButton.snp.trailing).offset(8)
            maker.trailing.equalToSuperview().inset(16)
        }

        descriptionLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(4)
            maker.leading.trailing.equalTo(titleLabel)
        }

        dateLabel.snp.makeConstraints { maker in
            maker.top.equalTo(descriptionLabel.snp.bottom).offset(4)
            maker.leading.trailing.equalTo(titleLabel)
            maker.bottom.equalToSuperview().offset(-12)
        }
    }

    // MARK: - UI Updates

    private func updateCompletionUI(with completed: Bool) {
        let titleText = todo?.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let displayTitle = titleText.isEmpty ? todo?.description ?? "" : titleText

        let attributedText = NSMutableAttributedString(string: displayTitle)
        if completed {
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                        value: NSUnderlineStyle.single.rawValue,
                                        range: NSRange(location: 0, length: displayTitle.count))
        }
        titleLabel.attributedText = attributedText

        let imageName = completed ? "checkmark.circle.fill" : "circle"
        completedButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Configuration

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
        selectCompletion?()
    }
}
